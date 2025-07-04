import 'package:agendanova/core/constants/firestore_collections.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/models/sessao_model.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Implementação concreta do SessaoRepository que usa o FirebaseDatasource
class SessaoRepositoryImpl implements SessaoRepository {
  final FirebaseDatasource _firebaseDatasource;

  SessaoRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Sessao>> getSessoes() {
    return Stream.value([]);
  }

  @override
  Stream<List<Sessao>> getSessoesByTreinamentoId(String treinamentoId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Sessao>> getSessoesByDate(DateTime date) {
    final docId = DateFormat('yyyy-MM-dd').format(date);

    return _firebaseDatasource.getDocumentByIdStream(FirestoreCollections.sessoes, docId)
        .map((docSnapshot) {
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return [];
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      List<Sessao> sessoesDoDia = [];

      // Verifica se o dia inteiro está bloqueado por um campo no documento
      final bool isDayBlockedFlag = data['isDayBlocked'] as bool? ?? false;

      if (isDayBlockedFlag) {
        // Se o dia está bloqueado, retorna uma lista de sessões bloqueadas
        // APENAS para os horários que estão na agenda de disponibilidade (se for o caso)
        // ou todos os horários padrão se não houver agenda específica para o dia.
        // A lógica de quais horários são "disponíveis" para um dia bloqueado
        // é melhor tratada no ViewModel combinando com a agenda de disponibilidade.
        // Aqui, apenas criamos uma sessão "fantasma" para indicar o bloqueio do dia.
        sessoesDoDia.add(Sessao(
          id: '${docId}-dia-bloqueado', // ID único para o bloqueio do dia
          treinamentoId: 'dia_bloqueado_completo', // ID especial para bloqueio de dia
          pacienteId: 'dia_bloqueado_completo',
          pacienteNome: 'Dia Bloqueado',
          dataHora: DateTime(date.year, date.month, date.day, 0, 0), // Apenas a data para o bloqueio do dia
          numeroSessao: 0,
          status: 'Bloqueada',
          statusPagamento: 'N/A',
          formaPagamento: 'N/A',
          agendamentoStartDate: date,
          totalSessoes: 0,
          reagendada: false,
          observacoes: 'Dia inteiro bloqueado',
        ));
      } else {
        // Se o dia não está bloqueado, itera sobre os horários individuais
        data.forEach((horarioKey, sessaoMap) {
          // Garante que não estamos tentando parsear o campo 'isDayBlocked' como uma sessão
          if (horarioKey != 'isDayBlocked' && sessaoMap is Map<String, dynamic>) {
            try {
              sessoesDoDia.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
            } catch (e) {
              print('Erro ao parsear sessão para $horarioKey em $docId: $e');
            }
          }
        });
      }

      sessoesDoDia.sort((a, b) => a.dataHora.compareTo(b.dataHora));
      return sessoesDoDia;
    });
  }

  @override
  Stream<List<Sessao>> getSessoesByMonth(DateTime monthDate) {
    final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final startDocId = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final endDocId = DateFormat('yyyy-MM-dd').format(endOfMonth);

    return _firebaseDatasource.queryCollectionStreamByDocIdRange(
      FirestoreCollections.sessoes,
      startDocId: startDocId,
      endDocId: endDocId,
    ).map((querySnapshot) {
      List<Sessao> sessoesDoMes = [];
      for (var docSnapshot in querySnapshot.docs) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final docId = docSnapshot.id;

          // Adiciona a sessão "fantasma" de bloqueio de dia inteiro se o flag estiver true
          final bool isDayBlockedFlag = data['isDayBlocked'] as bool? ?? false;
          if (isDayBlockedFlag) {
            sessoesDoMes.add(Sessao(
              id: '${docId}-dia-bloqueado',
              treinamentoId: 'dia_bloqueado_completo',
              pacienteId: 'dia_bloqueado_completo',
              pacienteNome: 'Dia Bloqueado',
              dataHora: DateTime(int.parse(docId.split('-')[0]), int.parse(docId.split('-')[1]), int.parse(docId.split('-')[2])),
              numeroSessao: 0,
              status: 'Bloqueada',
              statusPagamento: 'N/A',
              formaPagamento: 'N/A',
              agendamentoStartDate: DateTime(int.parse(docId.split('-')[0]), int.parse(docId.split('-')[1]), int.parse(docId.split('-')[2])),
              totalSessoes: 0,
              reagendada: false,
              observacoes: 'Dia inteiro bloqueado',
            ));
          }

          // Itera sobre os horários individuais (excluindo o flag de bloqueio)
          data.forEach((horarioKey, sessaoMap) {
            if (horarioKey != 'isDayBlocked' && sessaoMap is Map<String, dynamic>) {
              try {
                sessoesDoMes.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
              } catch (e) {
                print('Erro ao parsear sessão para $horarioKey em $docId: $e');
              }
            }
          });
        }
      }
      return sessoesDoMes;
    });
  }

  @override
  Future<void> setDayBlockedStatus(DateTime date, bool isBlocked) async {
    final docId = DateFormat('yyyy-MM-dd').format(date);
    await _firebaseDatasource.setDocument(
      FirestoreCollections.sessoes,
      docId,
      {'isDayBlocked': isBlocked},
      SetOptions(merge: true),
    );
    if (!isBlocked) {
      final sessionsForDay = await getSessoesByDate(date).first;
      final blockedIndividualSessions = sessionsForDay
          .where((s) => s.treinamentoId == 'bloqueio_manual' && s.status == 'Bloqueada' && s.id != null)
          .map((s) => s.id!)
          .toList();
      if (blockedIndividualSessions.isNotEmpty) {
        await deleteMultipleSessoes(blockedIndividualSessions);
      }
    }
  }


  @override
  Future<String> addSessao(Sessao sessao) async {
    final docId = DateFormat('yyyy-MM-dd').format(sessao.dataHora);
    final horarioKey = DateFormat('HH:mm').format(sessao.dataHora); // Garante HH:mm

    Map<String, dynamic> dataToSave;
    // Verifica se é uma sessão de bloqueio manual para salvar de forma simplificada
    if (sessao.treinamentoId == 'bloqueio_manual' && sessao.status == 'Bloqueada') {
      dataToSave = {
        'status': 'Bloqueada',
        'treinamentoId': 'bloqueio_manual',
        'observacoes': sessao.observacoes, // Manter observações se houver
      };
    } else {
      final sessaoModel = SessaoModel.fromEntity(sessao);
      dataToSave = sessaoModel.toFirestore();
    }

    await _firebaseDatasource.setDocument(
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: dataToSave}, // Usa HH:mm como chave
      SetOptions(merge: true), // Garante que o documento do dia seja criado/mesclado
    );
    return '$docId-$horarioKey';
  }

  @override
  Future<void> addMultipleSessoes(List<Sessao> sessoes) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var sessao in sessoes) {
      final docId = DateFormat('yyyy-MM-dd').format(sessao.dataHora);
      final horarioKey = DateFormat('HH:mm').format(sessao.dataHora);
      
      Map<String, dynamic> dataToSave;
      if (sessao.treinamentoId == 'bloqueio_manual' && sessao.status == 'Bloqueada') {
        dataToSave = {
          'status': 'Bloqueada',
          'treinamentoId': 'bloqueio_manual',
        };
      } else {
        final sessaoModel = SessaoModel.fromEntity(sessao);
        dataToSave = sessaoModel.toFirestore();
      }

      final docRef = _firebaseDatasource.getCollectionRef(FirestoreCollections.sessoes).doc(docId);

      batch.set(docRef, {horarioKey: dataToSave}, SetOptions(merge: true));
    }
    await batch.commit();
  }


  @override
  Future<void> updateSessao(Sessao sessao) async {
    if (sessao.id == null) {
      throw Exception('ID da sessão é obrigatório para atualização.');
    }
    final parts = sessao.id!.split('-');
    final docId = '${parts[0]}-${parts[1]}-${parts[2]}';
    final rawHorarioKey = parts[3];
    final horarioKey = '${rawHorarioKey.substring(0, 2)}:${rawHorarioKey.substring(2, 4)}';

    Map<String, dynamic> dataToSave;
    if (sessao.treinamentoId == 'bloqueio_manual' && sessao.status == 'Bloqueada') {
      dataToSave = {
        'status': 'Bloqueada',
        'treinamentoId': 'bloqueio_manual',
      };
    } else {
      final sessaoModel = SessaoModel.fromEntity(sessao);
      dataToSave = sessaoModel.toFirestore();
    }

    await _firebaseDatasource.updateDocument( // updateDocument não usa merge por padrão
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: dataToSave},
    );
  }

  @override
  Future<void> deleteSessao(String id) async {
    final parts = id.split('-');
    final docId = '${parts[0]}-${parts[1]}-${parts[2]}';
    final rawHorarioKey = parts[3];
    final horarioKey = '${rawHorarioKey.substring(0, 2)}:${rawHorarioKey.substring(2, 4)}';

    await _firebaseDatasource.updateDocument(
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: FieldValue.delete()},
    );
  }

  @override
  Future<void> deleteMultipleSessoes(List<String> sessaoIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var id in sessaoIds) {
      final parts = id.split('-');
      final docId = '${parts[0]}-${parts[1]}-${parts[2]}';
      final rawHorarioKey = parts[3];
      final horarioKey = '${rawHorarioKey.substring(0, 2)}:${rawHorarioKey.substring(2, 4)}';

      final docRef = _firebaseDatasource.getDocumentRef(FirestoreCollections.sessoes, docId);
      batch.update(docRef, {horarioKey: FieldValue.delete()});
    }
    await batch.commit();
  }
}
