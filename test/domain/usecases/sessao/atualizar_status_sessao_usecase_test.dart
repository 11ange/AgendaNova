// test/domain/usecases/sessao/atualizar_status_sessao_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

@GenerateMocks([
  SessaoRepository,
  TreinamentoRepository,
  AgendaDisponibilidadeRepository,
  PacienteRepository,
])
import 'atualizar_status_sessao_usecase_test.mocks.dart';

void main() {
  late AtualizarStatusSessaoUseCase usecase;
  late MockSessaoRepository mockSessaoRepository;
  late MockTreinamentoRepository mockTreinamentoRepository;
  late MockAgendaDisponibilidadeRepository mockAgendaRepository;
  late MockPacienteRepository mockPacienteRepository;

  setUp(() async {
    mockSessaoRepository = MockSessaoRepository();
    mockTreinamentoRepository = MockTreinamentoRepository();
    mockAgendaRepository = MockAgendaDisponibilidadeRepository();
    mockPacienteRepository = MockPacienteRepository();
    usecase = AtualizarStatusSessaoUseCase(
      mockSessaoRepository,
      mockTreinamentoRepository,
      mockAgendaRepository,
      mockPacienteRepository,
    );
    await initializeDateFormatting('pt_BR', null);
    Intl.defaultLocale = 'pt_BR';
  });

  group('AtualizarStatusSessaoUseCase', () {
    final treinamentoId = 'treinamento-id-1';
    final pacienteId = 'paciente-id-1';

    final paciente = Paciente(
      id: pacienteId,
      nome: 'Paciente Teste',
      dataNascimento: DateTime(2010, 1, 1),
      nomeResponsavel: 'Responsável Teste',
      dataCadastro: DateTime.now(),
      status: 'ativo',
    );

    final treinamento = Treinamento(
      id: treinamentoId,
      pacienteId: pacienteId,
      diaSemana: 'Segunda-feira',
      horario: '14:30',
      numeroSessoesTotal: 3,
      dataInicio: DateTime(2025, 9, 1),
      dataFimPrevista: DateTime(2025, 9, 15),
      status: 'ativo',
      formaPagamento: 'Pix',
      dataCadastro: DateTime.now(),
    );

    final sessaoAgendada1 = Sessao(
      id: 'sessao-id-1',
      treinamentoId: treinamentoId,
      pacienteId: pacienteId,
      pacienteNome: 'Paciente Teste',
      dataHora: DateTime(2025, 9, 1),
      numeroSessao: 1,
      status: 'Agendada',
      statusPagamento: 'Pendente',
      formaPagamento: 'Pix',
      agendamentoStartDate: DateTime(2025, 9, 1),
      totalSessoes: 3,
    );
    final sessaoAgendada2 = sessaoAgendada1.copyWith(id: 'sessao-id-2', numeroSessao: 2, dataHora: DateTime(2025, 9, 8));
    final sessaoAgendada3 = sessaoAgendada1.copyWith(id: 'sessao-id-3', numeroSessao: 3, dataHora: DateTime(2025, 9, 15));
    
    final sessoesDoTreinamento = [sessaoAgendada1, sessaoAgendada2, sessaoAgendada3];

    void setupDefaultMocks() {
      reset(mockSessaoRepository);
      reset(mockTreinamentoRepository);
      reset(mockAgendaRepository);
      reset(mockPacienteRepository);
      
      when(mockTreinamentoRepository.getTreinamentoById(any)).thenAnswer((_) async => treinamento);
      when(mockSessaoRepository.getSessoesByTreinamentoIdOnce(any)).thenAnswer((_) async => sessoesDoTreinamento);
      when(mockSessaoRepository.getSessoesByTreinamentoId(any)).thenAnswer((_) => Stream.value(sessoesDoTreinamento));
      when(mockSessaoRepository.updateSessao(any)).thenAnswer((_) async => Future.value());
      when(mockTreinamentoRepository.updateTreinamento(any)).thenAnswer((_) async => Future.value());
      when(mockSessaoRepository.addSessao(any)).thenAnswer((_) async => 'sessao-extra-id');
      when(mockSessaoRepository.deleteSessao(any)).thenAnswer((_) async => Future.value());
      when(mockAgendaRepository.getAgendaDisponibilidade())
        .thenAnswer((_) => Stream.value(AgendaDisponibilidade(agenda: {'Segunda-feira': ['14:30']})));
      when(mockSessaoRepository.getSessoesByDate(any)).thenAnswer((_) => Stream.value([]));
      when(mockPacienteRepository.getPacienteById(any)).thenAnswer((_) async => paciente);
    }
    
    void verifySessaoAtualizada(String id, String status, {int? numeroSessao}) {
      verify(mockSessaoRepository.updateSessao(
        argThat(predicate((s) =>
            s is Sessao &&
            s.id == id &&
            s.status == status &&
            (numeroSessao == null || s.numeroSessao == numeroSessao))),
      )).called(greaterThanOrEqualTo(1));
    }

        test('deve atualizar o status para Realizada e verificar o status do treinamento', () async {
      setupDefaultMocks();

      final sessoesQuaseConcluidas = [
        sessaoAgendada1.copyWith(status: 'Realizada'),
        sessaoAgendada2.copyWith(status: 'Realizada'),
        sessaoAgendada3,
      ];

      when(mockSessaoRepository.getSessoesByTreinamentoIdOnce(treinamentoId))
          .thenAnswer((_) async => sessoesQuaseConcluidas);

      await usecase.call(sessao: sessaoAgendada3, novoStatus: 'Realizada');

      verifySessaoAtualizada(sessaoAgendada3.id!, 'Realizada');
      verify(mockTreinamentoRepository.updateTreinamento(
              argThat(predicate((t) => t is Treinamento && t.status == 'Pendente Pagamento'))))
          .called(1);
    });

    test('deve reverter o status para Agendada e *NÃO* alterar o status do treinamento se ele já estiver ativo', () async {
      setupDefaultMocks();
      final sessaoRealizada = sessaoAgendada1.copyWith(status: 'Realizada');
      
      final treinamentoPendente = treinamento.copyWith(status: 'Pendente Pagamento');
      when(mockTreinamentoRepository.getTreinamentoById(treinamentoId)).thenAnswer((_) async => treinamentoPendente);

      await usecase.call(sessao: sessaoRealizada, novoStatus: 'Agendada');

      verifySessaoAtualizada(sessaoRealizada.id!, 'Agendada');
      verify(mockTreinamentoRepository.updateTreinamento(
              argThat(predicate((t) => t is Treinamento && t.status == 'ativo'))))
          .called(1);
    });

    test('deve lançar uma exceção se a mudança de status for inválida', () async {
      setupDefaultMocks();
      final sessaoRealizada = sessaoAgendada1.copyWith(status: 'Realizada');

      expect(
        () => usecase.call(sessao: sessaoRealizada, novoStatus: 'Falta'),
        throwsA(isA<Exception>()),
      );

      verifyNever(mockSessaoRepository.updateSessao(any));
    });

    test('deve criar uma sessão extra quando uma sessão é cancelada (sem desmarcar todas futuras)', () async {
      setupDefaultMocks();

      await usecase.call(sessao: sessaoAgendada1, novoStatus: 'Cancelada', desmarcarTodasFuturas: false);

      verifySessaoAtualizada(sessaoAgendada1.id!, 'Cancelada');
      verify(mockSessaoRepository.addSessao(any)).called(1);
    });

    test('deve desmarcar todas as sessões futuras quando a flag for true', () async {
      setupDefaultMocks();
      
      await usecase.call(sessao: sessaoAgendada1, novoStatus: 'Cancelada', desmarcarTodasFuturas: true);
      
      verifySessaoAtualizada(sessaoAgendada1.id!, 'Cancelada');
      verifySessaoAtualizada(sessaoAgendada2.id!, 'Cancelada');
      verifySessaoAtualizada(sessaoAgendada3.id!, 'Cancelada');
      
      verifyNever(mockSessaoRepository.addSessao(any));
    });

    test('deve remover a sessão extra quando o status é revertido de Cancelada para Agendada', () async {
      setupDefaultMocks();
      final sessaoCancelada = sessaoAgendada1.copyWith(status: 'Cancelada');
      
      final sessoesComExtra = [
        sessaoCancelada,
        sessaoAgendada2,
        sessaoAgendada3.copyWith(id: 'sessao-extra-id', numeroSessao: 4, reagendada: true, dataHora: DateTime(2025, 9, 22)),
      ];

      when(mockSessaoRepository.getSessoesByTreinamentoIdOnce(treinamentoId))
          .thenAnswer((_) async => sessoesComExtra);

      await usecase.call(sessao: sessaoCancelada, novoStatus: 'Agendada');
      
      verifySessaoAtualizada(sessaoCancelada.id!, 'Agendada');
      
      verify(mockSessaoRepository.deleteSessao('sessao-extra-id')).called(1);
    });

  });
}