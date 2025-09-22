import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
import 'package:agenda_treinamento/domain/repositories/lista_espera_repository.dart';

// Use case para editar um item da lista de espera
class EditarListaEsperaUseCase {
  final ListaEsperaRepository _listaEsperaRepository;

  EditarListaEsperaUseCase(this._listaEsperaRepository);

  Future<void> call(ListaEspera item) async {
    // Validações podem ser adicionadas aqui se necessário
    await _listaEsperaRepository.updateListaEspera(item);
  }
}