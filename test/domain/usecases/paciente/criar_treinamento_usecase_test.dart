// test/domain/usecases/treinamento/criar_treinamento_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/treinamento/criar_treinamento_usecase.dart';
import 'dart:async';

// Gera os mocks
@GenerateMocks([
  TreinamentoRepository,
  SessaoRepository,
  PacienteRepository,
  AgendaDisponibilidadeRepository,
])
import 'criar_treinamento_usecase_test.mocks.dart';

void main() {
  late CriarTreinamentoUseCase usecase;
  late MockTreinamentoRepository mockTreinamentoRepository;
  late MockSessaoRepository mockSessaoRepository;
  late MockPacienteRepository mockPacienteRepository;
  late MockAgendaDisponibilidadeRepository mockAgendaRepository;

  // Variáveis de dados de teste
  const pacienteId = 'paciente-id-1';
  final paciente = Paciente(
    id: pacienteId,
    nome: 'João da Silva',
    dataNascimento: DateTime(2010, 1, 1),
    nomeResponsavel: 'Maria da Silva',
    dataCadastro: DateTime.now(),
    status: 'ativo',
  );
  const diaSemana = 'Segunda-feira';
  const horario = '14:30';
  const numeroSessoesTotal = 10;
  final dataInicio = DateTime.now();
  const formaPagamento = 'Pix';
  final agendaDisponivel = AgendaDisponibilidade(agenda: {
    'Segunda-feira': ['14:30'],
  });
  final agendaIndisponivel = AgendaDisponibilidade(agenda: {});

  setUp(() {
    mockTreinamentoRepository = MockTreinamentoRepository();
    mockSessaoRepository = MockSessaoRepository();
    mockPacienteRepository = MockPacienteRepository();
    mockAgendaRepository = MockAgendaDisponibilidadeRepository();
    usecase = CriarTreinamentoUseCase(
      mockTreinamentoRepository,
      mockSessaoRepository,
      mockPacienteRepository,
      mockAgendaRepository,
    );
  });

  group('CriarTreinamentoUseCase', () {
    test('deve criar o treinamento e as sessões com sucesso', () async {
      // ARRANGE
      when(mockTreinamentoRepository.hasActiveTreinamento(any)).thenAnswer((_) async => false);
      when(mockTreinamentoRepository.hasOverlap(any, any)).thenAnswer((_) async => false);
      when(mockAgendaRepository.getAgendaDisponibilidade()).thenAnswer((_) => Stream.value(agendaDisponivel));
      when(mockPacienteRepository.getPacienteById(any)).thenAnswer((_) async => paciente);
      when(mockTreinamentoRepository.addTreinamento(any)).thenAnswer((_) async => 'novo-treinamento-id');
      when(mockSessaoRepository.addMultipleSessoes(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(
        pacienteId: pacienteId,
        diaSemana: diaSemana,
        horario: horario,
        numeroSessoesTotal: numeroSessoesTotal,
        dataInicio: dataInicio,
        formaPagamento: formaPagamento,
      );

      // ASSERT
      verify(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).called(1);
      verify(mockTreinamentoRepository.hasOverlap(diaSemana, horario)).called(1);
      verify(mockAgendaRepository.getAgendaDisponibilidade()).called(1);
      verify(mockPacienteRepository.getPacienteById(pacienteId)).called(1);
      verify(mockTreinamentoRepository.addTreinamento(any)).called(1);
      verify(mockSessaoRepository.addMultipleSessoes(any)).called(1);
    });

    test('deve lançar uma exceção se o paciente já possui um treinamento em andamento', () async {
      // ARRANGE
      when(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).thenAnswer((_) async => true);

      // ACT & ASSERT
      await expectLater(
        () async => await usecase.call(
          pacienteId: pacienteId,
          diaSemana: diaSemana,
          horario: horario,
          numeroSessoesTotal: numeroSessoesTotal,
          dataInicio: dataInicio,
          formaPagamento: formaPagamento,
        ),
        throwsA(isA<Exception>()),
      );

      verify(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).called(1);
      verifyNever(mockTreinamentoRepository.hasOverlap(any, any));
      verifyNever(mockTreinamentoRepository.addTreinamento(any));
    });

    test('deve lançar uma exceção se já existe um treinamento agendado para o mesmo dia e horário', () async {
      // ARRANGE
      when(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).thenAnswer((_) async => false);
      when(mockTreinamentoRepository.hasOverlap(diaSemana, horario)).thenAnswer((_) async => true);

      // ACT & ASSERT
      await expectLater(
        () async => await usecase.call(
          pacienteId: pacienteId,
          diaSemana: diaSemana,
          horario: horario,
          numeroSessoesTotal: numeroSessoesTotal,
          dataInicio: dataInicio,
          formaPagamento: formaPagamento,
        ),
        throwsA(isA<Exception>()),
      );

      verify(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).called(1);
      verify(mockTreinamentoRepository.hasOverlap(diaSemana, horario)).called(1);
      verifyNever(mockAgendaRepository.getAgendaDisponibilidade());
      verifyNever(mockTreinamentoRepository.addTreinamento(any));
    });

    test('deve lançar uma exceção se o horário selecionado não está disponível na agenda', () async {
      // ARRANGE
      when(mockTreinamentoRepository.hasActiveTreinamento(any)).thenAnswer((_) async => false);
      when(mockTreinamentoRepository.hasOverlap(any, any)).thenAnswer((_) async => false);
      when(mockAgendaRepository.getAgendaDisponibilidade()).thenAnswer((_) => Stream.value(agendaIndisponivel));

      // ACT & ASSERT
      await expectLater(
        () async => await usecase.call(
          pacienteId: pacienteId,
          diaSemana: diaSemana,
          horario: horario,
          numeroSessoesTotal: numeroSessoesTotal,
          dataInicio: dataInicio,
          formaPagamento: formaPagamento,
        ),
        throwsA(isA<Exception>()),
      );

      verify(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).called(1);
      verify(mockTreinamentoRepository.hasOverlap(diaSemana, horario)).called(1);
      verify(mockAgendaRepository.getAgendaDisponibilidade()).called(1);
      verifyNever(mockTreinamentoRepository.addTreinamento(any));
    });
  });
}
