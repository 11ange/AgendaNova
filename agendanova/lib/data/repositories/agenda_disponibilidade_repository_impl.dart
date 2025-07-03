import 'package:flutter_agenda_fono/core/constants/firestore_collections.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/models/agenda_disponibilidade_model.dart';
import 'package:flutter_agenda_fono/domain/entities/agenda_disponibilidade.dart';
import 'package:flutter_agenda_fono/domain/repositories/agenda_disponibilidade_repository.dart';

// Implementação concreta do AgendaDisponibilidadeRepository que usa o FirebaseDatasource
class AgendaDisponibilidadeRepositoryImpl implements AgendaDisponibilidadeRepository {
  final FirebaseDatasource _firebaseDatasource;
  static const String _disponibilidadeDocId = 'horarios_padrao'; // ID fixo para o documento de disponibilidade

  AgendaDisponibilidadeRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<AgendaDisponibilidade?> getAgendaDisponibilidade() {
    return _firebaseDatasource.getDocumentByIdStream(FirestoreCollections.disponibilidade, _disponibilidadeDocId)
        .map((doc) {
      if (doc.exists) {
        return AgendaDisponibilidadeModel.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<void> setAgendaDisponibilidade(AgendaDisponibilidade agenda) async {
    final agendaModel = AgendaDisponibilidadeModel.fromEntity(agenda);
    await _firebaseDatasource.setDocument(
        FirestoreCollections.disponibilidade, _disponibilidadeDocId, agendaModel.toFirestore());
  }
}

