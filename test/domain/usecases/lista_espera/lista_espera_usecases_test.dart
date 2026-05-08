import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
import 'package:agenda_treinamento/domain/repositories/lista_espera_repository.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/adicionar_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/editar_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/remover_lista_espera_usecase.dart';

import 'lista_espera_usecases_test.mocks.dart';

@GenerateMocks([ListaEsperaRepository])
void main() {
  late MockListaEsperaRepository mockRepository;
  late AdicionarListaEsperaUseCase adicionarUseCase;
  late EditarListaEsperaUseCase editarUseCase;
  late RemoverListaEsperaUseCase removerUseCase;

  setUp(() {
    mockRepository = MockListaEsperaRepository();
    adicionarUseCase = AdicionarListaEsperaUseCase(mockRepository);
    editarUseCase = EditarListaEsperaUseCase(mockRepository);
    removerUseCase = RemoverListaEsperaUseCase(mockRepository);
  });

  final tItem = ListaEspera(
    id: '1',
    nome: 'João',
    dataCadastro: DateTime.now(),
    status: 'aguardando',
  );

  group('ListaEspera UseCases', () {
    test('AdicionarListaEsperaUseCase deve chamar o repositório', () async {
      when(mockRepository.adicionarListaEspera(any)).thenAnswer((_) async => {});
      await adicionarUseCase.call(tItem);
      verify(mockRepository.adicionarListaEspera(tItem)).called(1);
    });

    test('EditarListaEsperaUseCase deve chamar o repositório', () async {
      when(mockRepository.updateListaEspera(any)).thenAnswer((_) async => {});
      await editarUseCase.call(tItem);
      verify(mockRepository.updateListaEspera(tItem)).called(1);
    });

    test('RemoverListaEsperaUseCase deve chamar o repositório', () async {
      when(mockRepository.removerListaEspera(any)).thenAnswer((_) async => {});
      await removerUseCase.call('1');
      verify(mockRepository.removerListaEspera('1')).called(1);
    });
  });
}
