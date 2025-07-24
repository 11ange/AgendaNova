import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
import 'package:agenda_treinamento/domain/repositories/lista_espera_repository.dart';

// Use case para adicionar um novo item à lista de espera
class AdicionarListaEsperaUseCase {
  final ListaEsperaRepository _listaEsperaRepository;

  AdicionarListaEsperaUseCase(this._listaEsperaRepository);

  Future<void> call(ListaEspera item) async {
    // Nenhuma regra de negócio complexa para adicionar, apenas persistência.
    await _listaEsperaRepository.adicionarListaEspera(item);
  }
}

