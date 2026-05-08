import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/relatorio/gerar_relatorio_individual_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/relatorio/gerar_relatorio_mensal_global_usecase.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';

import 'relatorio_usecases_test.mocks.dart';

@GenerateMocks([SessaoRepository, TreinamentoRepository, PacienteRepository])
void main() {
  late MockSessaoRepository mockSessaoRepository;
  late MockTreinamentoRepository mockTreinamentoRepository;
  late MockPacienteRepository mockPacienteRepository;
  late GerarRelatorioIndividualPacienteUseCase usecaseIndividual;
  late GerarRelatorioMensalGlobalUseCase usecaseMensal;

  setUp(() {
    mockSessaoRepository = MockSessaoRepository();
    mockTreinamentoRepository = MockTreinamentoRepository();
    mockPacienteRepository = MockPacienteRepository();
    usecaseIndividual = GerarRelatorioIndividualPacienteUseCase(
      mockSessaoRepository,
      mockTreinamentoRepository,
      mockPacienteRepository,
    );
    usecaseMensal = GerarRelatorioMensalGlobalUseCase(
      mockSessaoRepository,
      mockTreinamentoRepository,
    );
  });

  final tPaciente = Paciente(
    id: 'p1',
    nome: 'Paciente Teste',
    dataNascimento: DateTime(2000, 1, 1),
    nomeResponsavel: 'Responsavel',
    dataCadastro: DateTime.now(),
    status: 'ativo',
  );

  group('Relatorio UseCases', () {
    test('GerarRelatorioIndividualPacienteUseCase deve retornar relatório formatado', () async {
      when(mockPacienteRepository.getPacienteById('p1'))
          .thenAnswer((_) async => tPaciente);
      when(mockTreinamentoRepository.getTreinamentosByPacienteId('p1'))
          .thenAnswer((_) => Stream.value([]));

      final result = await usecaseIndividual.call('p1');

      expect(result.tipoRelatorio, 'Individual Paciente');
      expect(result.dados['pacienteNome'], 'Paciente Teste');
      verify(mockPacienteRepository.getPacienteById('p1')).called(1);
    });

    test('GerarRelatorioMensalGlobalUseCase deve retornar relatório consolidado', () async {
      when(mockSessaoRepository.getSessoes()).thenAnswer((_) => Stream.value([]));
      when(mockTreinamentoRepository.getTreinamentos()).thenAnswer((_) => Stream.value([]));

      final result = await usecaseMensal.call(2026, 5);

      expect(result.tipoRelatorio, 'Mensal Global');
      expect(result.dados['Mês'], 5);
      verify(mockSessaoRepository.getSessoes()).called(1);
    });
  });
}
