// test/domain/usecases/agenda/definir_agenda_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/usecases/agenda/definir_agenda_usecase.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

@GenerateMocks([AgendaDisponibilidadeRepository, SessaoRepository])
import 'definir_agenda_usecase_test.mocks.dart';

void main() {
  late DefinirAgendaUseCase usecase;
  late MockAgendaDisponibilidadeRepository mockAgendaRepository;
  late MockSessaoRepository mockSessaoRepository;

  late DateTime hoje;
  late DateTime amanha;
  late String diaAmanhaNorm;
  late String outroDiaNorm;
  const horaSessao = '10:00';
  late AgendaDisponibilidade agendaAtual;
  late Sessao sessaoFutura;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
    Intl.defaultLocale = 'pt_BR';
  });

  setUp(() {
    mockAgendaRepository = MockAgendaDisponibilidadeRepository();
    mockSessaoRepository = MockSessaoRepository();
    usecase = DefinirAgendaUseCase(
      mockAgendaRepository,
      mockSessaoRepository,
    );

    hoje = DateTime.now();
    amanha = hoje.add(const Duration(days: 1));

    // Usa o helper para garantir que as chaves da agenda estejam capitalizadas como o sistema espera
    diaAmanhaNorm = DateFormatter.getCapitalizedWeekdayName(amanha);
    outroDiaNorm = DateFormatter.getCapitalizedWeekdayName(hoje.add(const Duration(days: 2)));

    agendaAtual = AgendaDisponibilidade(agenda: {
      diaAmanhaNorm: [horaSessao],
      outroDiaNorm: ['11:00'],
    });

    sessaoFutura = Sessao(
      id: 'sessao-id-1',
      treinamentoId: 'treinamento-id-1',
      pacienteId: 'paciente-id-1',
      pacienteNome: 'Paciente Teste',
      dataHora: DateTime(amanha.year, amanha.month, amanha.day, 10, 0),
      numeroSessao: 1,
      status: 'Agendada',
      statusPagamento: 'Pendente',
      formaPagamento: 'Pix',
      agendamentoStartDate: hoje,
      totalSessoes: 10,
    );
  });

  group('DefinirAgendaUseCase', () {
    test('deve lançar uma exceção se a nova agenda remover um horário com sessões futuras', () async {
      final novaAgenda = AgendaDisponibilidade(agenda: {
        outroDiaNorm: ['11:00'],
      });

      when(mockAgendaRepository.getAgendaDisponibilidade()).thenAnswer((_) => Stream.value(agendaAtual));
      when(mockSessaoRepository.getSessoes()).thenAnswer((_) => Stream.value([sessaoFutura]));

      // ACT & ASSERT
      final call = usecase.call(novaAgenda);
      await expectLater(call, throwsA(isA<Exception>()));

      verify(mockAgendaRepository.getAgendaDisponibilidade()).called(1);
      verify(mockSessaoRepository.getSessoes()).called(1);
      verifyNever(mockAgendaRepository.setAgendaDisponibilidade(any));
    });

    test('deve salvar a nova agenda se não houver conflitos de horário', () async {
      final novaAgenda = AgendaDisponibilidade(agenda: {
        outroDiaNorm: ['14:00'],
      });

      when(mockAgendaRepository.getAgendaDisponibilidade()).thenAnswer((_) => Stream.value(agendaAtual));
      when(mockSessaoRepository.getSessoes()).thenAnswer((_) => Stream.value([]));
      when(mockAgendaRepository.setAgendaDisponibilidade(any)).thenAnswer((_) async {});

      await usecase.call(novaAgenda);

      verify(mockAgendaRepository.getAgendaDisponibilidade()).called(1);
      verify(mockSessaoRepository.getSessoes()).called(1);
      verify(mockAgendaRepository.setAgendaDisponibilidade(novaAgenda)).called(1);
    });
  });
}
