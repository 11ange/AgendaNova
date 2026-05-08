import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/treinamento/cancelar_treinamento_usecase.dart';

import 'cancelar_treinamento_usecase_test.mocks.dart';

@GenerateMocks([TreinamentoRepository, SessaoRepository, PacienteRepository])
void main() {
  late MockTreinamentoRepository mockTreinamentoRepository;
  late MockSessaoRepository mockSessaoRepository;
  late MockPacienteRepository mockPacienteRepository;
  late CancelarTreinamentoUseCase usecase;

  setUp(() {
    mockTreinamentoRepository = MockTreinamentoRepository();
    mockSessaoRepository = MockSessaoRepository();
    mockPacienteRepository = MockPacienteRepository();
    usecase = CancelarTreinamentoUseCase(
      mockTreinamentoRepository, 
      mockSessaoRepository,
      mockPacienteRepository,
    );
  });

  final tPaciente = Paciente(
    id: 'p1',
    nome: 'João da Silva',
    dataNascimento: DateTime(2010, 5, 15),
    nomeResponsavel: 'Maria da Silva',
    dataCadastro: DateTime.now(),
    status: 'inativo',
  );

  final tSessao = Sessao(
    id: 's1',
    treinamentoId: 't1',
    pacienteId: 'p1',
    pacienteNome: 'João da Silva',
    dataHora: DateTime.now(),
    numeroSessao: 1,
    status: 'Agendada',
    statusPagamento: 'Pendente',
    formaPagamento: 'Pix',
    agendamentoStartDate: DateTime.now(),
    totalSessoes: 10,
  );

  group('CancelarTreinamentoUseCase', () {
    test('deve excluir o treinamento, suas sessões e reativar o paciente', () async {
      // ARRANGE
      when(mockSessaoRepository.getSessoesByTreinamentoIdOnce('t1'))
          .thenAnswer((_) async => [tSessao]);
      when(mockSessaoRepository.deleteSessao(any)).thenAnswer((_) async => Future.value());
      when(mockTreinamentoRepository.deleteTreinamento(any)).thenAnswer((_) async => Future.value());
      when(mockPacienteRepository.getPacienteById('p1')).thenAnswer((_) async => tPaciente);
      when(mockPacienteRepository.updatePaciente(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call('t1', 'p1');

      // ASSERT
      verify(mockSessaoRepository.getSessoesByTreinamentoIdOnce('t1')).called(1);
      verify(mockSessaoRepository.deleteSessao('s1')).called(1);
      verify(mockTreinamentoRepository.deleteTreinamento('t1')).called(1);
      verify(mockPacienteRepository.getPacienteById('p1')).called(1);
      verify(mockPacienteRepository.updatePaciente(argThat(
        predicate<Paciente>((p) => p.status == 'ativo')
      ))).called(1);
    });
  });
}
