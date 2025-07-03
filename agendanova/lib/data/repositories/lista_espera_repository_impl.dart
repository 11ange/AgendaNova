import 'package:flutter_agenda_fono/core/constants/firestore_collections.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/models/lista_espera_model.dart';
import 'package:flutter_agenda_fono/domain/entities/lista_espera.dart';
import 'package:flutter_agenda_fono/domain/repositories/lista_espera_repository.dart';

// Implementação concreta do ListaEsperaRepository que usa o FirebaseDatasource
class ListaEsperaRepositoryImpl implements ListaEsperaRepository {
  final FirebaseDatasource _firebaseDatasource;

  ListaEsperaRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<ListaEspera>> getListaEspera() {
    // A ordenação por data de cadastro (mais antigo primeiro) será feita no ViewModel
    // ou na camada de apresentação, pois orderBy() pode exigir índices no Firestore.
    // Conforme instruído, evitamos orderBy() diretamente na query Firestore.
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.listaEspera).map(
          (snapshot) => snapshot.docs
              .map((doc) => ListaEsperaModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> adicionarListaEspera(ListaEspera item) async {
    final itemModel = ListaEsperaModel.fromEntity(item);
    await _firebaseDatasource.addDocument(FirestoreCollections.listaEspera, itemModel.toFirestore());
  }

  @override
  Future<void> removerListaEspera(String id) async {
    await _firebaseDatasource.deleteDocument(FirestoreCollections.listaEspera, id);
  }
}

