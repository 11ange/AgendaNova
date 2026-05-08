import 'package:agenda_treinamento/core/constants/firestore_collections.dart';
import 'package:agenda_treinamento/data/datasources/firebase_datasource.dart';
import 'package:agenda_treinamento/data/models/agenda_disponibilidade_model.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';

// Implementação concreta do AgendaDisponibilidadeRepository que usa o FirebaseDatasource
class AgendaDisponibilidadeRepositoryImpl implements AgendaDisponibilidadeRepository {
  final FirebaseDatasource _firebaseDatasource;

  AgendaDisponibilidadeRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<AgendaDisponibilidade?> getAgendaDisponibilidade() {
    // Usa queryCollectionStream para aproveitar o filtro automático de ownerId (ou bypass de admin)
    // Buscamos o primeiro documento da coleção disponibilidade que pertence ao usuário
    return _firebaseDatasource
        .getCollectionStream(FirestoreCollections.disponibilidade)
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Se houver múltiplos (ex: admin vendo tudo), pegamos o primeiro por simplicidade 
        // ou poderíamos filtrar pelo usuário atual se necessário.
        return AgendaDisponibilidadeModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  @override
  Future<void> setAgendaDisponibilidade(AgendaDisponibilidade agenda) async {
    final currentUserId = _firebaseDatasource.currentUserId;
    if (currentUserId == null) return;

    final agendaModel = AgendaDisponibilidadeModel.fromEntity(agenda.copyWith(ownerId: currentUserId));
    
    // Verifica se já existe um documento de agenda para este usuário
    final snapshot = await _firebaseDatasource.queryCollectionOnce(
      FirestoreCollections.disponibilidade,
      field: 'ownerId',
      isEqualTo: currentUserId,
    );

    if (snapshot.docs.isNotEmpty) {
      // Atualiza o existente
      await _firebaseDatasource.updateDocument(
        FirestoreCollections.disponibilidade,
        snapshot.docs.first.id,
        agendaModel.toFirestore(),
      );
    } else {
      // Cria um novo usando o UID como ID para garantir unicidade
      await _firebaseDatasource.setDocument(
        FirestoreCollections.disponibilidade,
        currentUserId,
        agendaModel.toFirestore(),
      );
    }
  }
}

