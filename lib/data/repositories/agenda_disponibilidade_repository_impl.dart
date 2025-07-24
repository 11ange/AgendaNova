import 'package:agenda_treinamento/core/constants/firestore_collections.dart';
import 'package:agenda_treinamento/data/datasources/firebase_datasource.dart';
import 'package:agenda_treinamento/data/models/agenda_disponibilidade_model.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';

// Implementação concreta do AgendaDisponibilidadeRepository que usa o FirebaseDatasource
class AgendaDisponibilidadeRepositoryImpl implements AgendaDisponibilidadeRepository {
  final FirebaseDatasource _firebaseDatasource;
  // ID fixo para o documento de disponibilidade, conforme sua estrutura no Firestore
  static const String _disponibilidadeDocId = 'minha_agenda'; // ID do documento

  AgendaDisponibilidadeRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<AgendaDisponibilidade?> getAgendaDisponibilidade() {
    return _firebaseDatasource.getDocumentByIdStream(FirestoreCollections.disponibilidade, _disponibilidadeDocId)
        .map((doc) {
      if (doc.exists && doc.data() != null) { // Garante que o documento e os dados existam
        return AgendaDisponibilidadeModel.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<void> setAgendaDisponibilidade(AgendaDisponibilidade agenda) async {
    final agendaModel = AgendaDisponibilidadeModel.fromEntity(agenda);
    // Salva o mapa da agenda diretamente no documento 'minha_agenda'
    await _firebaseDatasource.setDocument(
        FirestoreCollections.disponibilidade, _disponibilidadeDocId, agendaModel.toFirestore());
  }
}

