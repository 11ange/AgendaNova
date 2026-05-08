// test/domain/usecases/paciente/cadastrar_paciente_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/cadastrar_paciente_usecase.dart';

// Importa o arquivo que será gerado pelo Mockito
import 'cadastrar_paciente_usecase_test.mocks.dart';

// 1. Anotação para gerar o mock do PacienteRepository
@GenerateMocks([PacienteRepository])
void main() {
  // 2. Declaração das variáveis que serão usadas nos testes
  late CadastrarPacienteUseCase usecase;
  late MockPacienteRepository mockPacienteRepository;

  // 3. O `setUp` é executado antes de cada teste individual
  setUp(() {
    // Cria uma nova instância do mock e do caso de uso para cada teste
    mockPacienteRepository = MockPacienteRepository();
    usecase = CadastrarPacienteUseCase(mockPacienteRepository);
  });

  // Cria um paciente de exemplo para usar nos testes
  final pacienteExemplo = Paciente(
    nome: 'João da Silva',
    dataNascimento: DateTime(2010, 5, 15),
    nomeResponsavel: 'Maria da Silva',
    dataCadastro: DateTime.now(),
    status: 'ativo',
  );

  // 4. Primeiro grupo de testes: descreve o que está sendo testado
  group('CadastrarPacienteUseCase', () {

    // Teste 1: Cenário de sucesso
    test('deve cadastrar o paciente com sucesso se o nome não existir', () async {
      // ARRANGE
      when(mockPacienteRepository.getPacienteByNormalizedName(any)).thenAnswer((_) async => null);
      when(mockPacienteRepository.addPaciente(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pacienteExemplo);

      // ASSERT
      verify(mockPacienteRepository.addPaciente(pacienteExemplo)).called(1);
    });

    // Teste 2: Cenário de falha (Duplicado exato)
    test('deve lançar DuplicatePacienteException se nome e data de nascimento coincidirem', () async {
      // ARRANGE
      when(mockPacienteRepository.getPacienteByNormalizedName(any))
          .thenAnswer((_) async => pacienteExemplo);

      // ACT
      final call = usecase.call;

      // ASSERT
      expect(() => call(pacienteExemplo), throwsA(isA<DuplicatePacienteException>()));
      verifyNever(mockPacienteRepository.addPaciente(any));
    });

    // Teste 3: Cenário de aviso de homônimo
    test('deve lançar HomonymPacienteException se o nome for igual mas a data de nascimento for diferente', () async {
      // ARRANGE
      final pacienteOutraData = pacienteExemplo.copyWith(dataNascimento: DateTime(1990, 1, 1));
      when(mockPacienteRepository.getPacienteByNormalizedName(any))
          .thenAnswer((_) async => pacienteExemplo);
      
      // ACT
      final call = usecase.call;

      // ASSERT
      expect(() => call(pacienteOutraData), throwsA(isA<HomonymPacienteException>()));
    });

    // Teste 4: Cenário de falha (Duplicado com paciente arquivado)
    test('deve lançar DuplicatePacienteException se houver um paciente ARQUIVADO com mesmo nome e data', () async {
      // ARRANGE
      final pacienteArquivado = pacienteExemplo.copyWith(id: 'old_id', status: 'arquivado');
      
      when(mockPacienteRepository.getPacienteByNormalizedName(any))
          .thenAnswer((_) async => pacienteArquivado);

      // ACT
      final call = usecase.call;

      // ASSERT
      expect(() => call(pacienteExemplo), throwsA(isA<DuplicatePacienteException>()));
      verifyNever(mockPacienteRepository.addPaciente(any));
    });

    // Teste 5: Sucesso ao ignorar homônimo
    test('deve cadastrar com sucesso ao ignorar aviso de homônimo', () async {
      // ARRANGE
      final pacienteOutraData = pacienteExemplo.copyWith(dataNascimento: DateTime(1990, 1, 1));
      when(mockPacienteRepository.getPacienteByNormalizedName(any))
          .thenAnswer((_) async => pacienteExemplo);
      when(mockPacienteRepository.addPaciente(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pacienteOutraData, ignoreHomonym: true);

      // ASSERT
      verify(mockPacienteRepository.addPaciente(pacienteOutraData)).called(1);
    });
  });
}