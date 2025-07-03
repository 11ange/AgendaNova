import 'package:agendanova/domain/repositories/lista_espera_repository.dart';

// Use case para remover um item da lista de espera
class RemoverListaEsperaUseCase {
  final ListaEsperaRepository _listaEsperaRepository;

  RemoverListaEsperaUseCase(this._listaEsperaRepository);

  Future<void> call(String itemId) async {
    // Nenhuma regra de negócio complexa para remover, apenas persistência.
    await _listaEsperaRepository.removerListaEspera(itemId);
  }
}

