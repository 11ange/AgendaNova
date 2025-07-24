import 'package:agenda_treinamento/core/constants/firestore_collections.dart';
import 'package:agenda_treinamento/data/datasources/firebase_datasource.dart';
import 'package:agenda_treinamento/data/models/relatorio_model.dart';
import 'package:agenda_treinamento/domain/entities/relatorio.dart';
import 'package:agenda_treinamento/domain/repositories/relatorio_repository.dart';

// Implementação concreta do RelatorioRepository que usa o FirebaseDatasource
class RelatorioRepositoryImpl implements RelatorioRepository {
  final FirebaseDatasource _firebaseDatasource;

  RelatorioRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Relatorio>> getRelatorios() {
    // Se os relatórios forem persistidos no Firestore, você pode obter um stream aqui.
    // Por enquanto, retorna um stream vazio, pois a geração é em tempo real.
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.relatorios).map(
          (snapshot) => snapshot.docs
              .map((doc) => RelatorioModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> saveRelatorio(Relatorio relatorio) async {
    // Este método é opcional, dependendo se você deseja salvar os relatórios gerados
    // no Firestore para histórico. Se sim, descomente e implemente.
    final relatorioModel = RelatorioModel.fromEntity(relatorio);
    await _firebaseDatasource.setDocument(FirestoreCollections.relatorios, relatorio.id, relatorioModel.toFirestore());
  }
}

