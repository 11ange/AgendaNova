// test/domain/usecases/paciente/cadastrar_paciente_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/usecases/paciente/cadastrar_paciente_usecase.dart';

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
      // ARRANGE (Organizar)
      // Configura o mock: quando `pacienteExistsByName` for chamado com qualquer nome,
      // ele deve retornar `Future.value(false)`, indicando que o paciente não existe.
      when(mockPacienteRepository.pacienteExistsByName(any)).thenAnswer((_) async => false);
      // Configura o mock: quando `addPaciente` for chamado, ele deve completar com sucesso.
      when(mockPacienteRepository.addPaciente(any)).thenAnswer((_) async => Future.value());

      // ACT (Agir)
      // Executa o caso de uso com o paciente de exemplo.
      await usecase.call(pacienteExemplo);

      // ASSERT (Verificar)
      // Verifica se o método `addPaciente` do repositório foi chamado exatamente uma vez.
      verify(mockPacienteRepository.addPaciente(pacienteExemplo)).called(1);
    });

    // Teste 2: Cenário de falha
    test('deve lançar uma exceção se um paciente com o mesmo nome já existir', () async {
      // ARRANGE (Organizar)
      // Configura o mock: desta vez, `pacienteExistsByName` retorna `true`.
      when(mockPacienteRepository.pacienteExistsByName(any)).thenAnswer((_) async => true);

      // ACT (Agir)
      // Chamamos o caso de uso e esperamos que ele lance uma exceção.
      final call = usecase.call;

      // ASSERT (Verificar)
      // Verifica se a chamada da função `call` com o paciente de exemplo
      // realmente lança uma exceção do tipo `Exception`.
      expect(() => call(pacienteExemplo), throwsA(isA<Exception>()));

      // Verifica também que, em caso de falha, o método `addPaciente` NUNCA seja chamado.
      verifyNever(mockPacienteRepository.addPaciente(any));
    });
  });
}