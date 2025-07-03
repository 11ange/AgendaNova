import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_agenda_fono/domain/entities/sessao.dart';

// Modelo de dados para a entidade Sessão, com métodos para serialização/desserialização do Firestore
class SessaoModel extends Sessao {
  SessaoModel({
    String? id,
    required String treinamentoId,
    required String pacienteId,
    required DateTime dataHora,
    required int numeroSessao,
    required String status,
    required String statusPagamento,
    DateTime? dataPagamento,
    String? observacoes,
  }) : super(
          id: id,
          treinamentoId: treinamentoId,
          pacienteId: pacienteId,
          dataHora: dataHora,
          numeroSessao: numeroSessao,
          status: status,
          statusPagamento: statusPagamento,
          dataPagamento: dataPagamento,
          observacoes: observacoes,
        );

  // Construtor para criar um SessaoModel a partir de um DocumentSnapshot do Firestore
  factory SessaoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessaoModel(
      id: doc.id,
      treinamentoId: data['treinamentoId'] as String,
      pacienteId: data['pacienteId'] as String,
      dataHora: (data['dataHora'] as Timestamp).toDate(),
      numeroSessao: data['numeroSessao'] as int,
      status: data['status'] as String,
      statusPagamento: data['statusPagamento'] as String,
      dataPagamento: (data['dataPagamento'] as Timestamp?)?.toDate(),
      observacoes: data['observacoes'] as String?,
    );
  }

  // Converte o SessaoModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'treinamentoId': treinamentoId,
      'pacienteId': pacienteId,
      'dataHora': Timestamp.fromDate(dataHora),
      'numeroSessao': numeroSessao,
      'status': status,
      'statusPagamento': statusPagamento,
      'dataPagamento': dataPagamento != null ? Timestamp.fromDate(dataPagamento!) : null,
      'observacoes': observacoes,
    };
  }

  // Construtor para criar um SessaoModel a partir de uma entidade Sessao
  factory SessaoModel.fromEntity(Sessao sessao) {
    return SessaoModel(
      id: sessao.id,
      treinamentoId: sessao.treinamentoId,
      pacienteId: sessao.pacienteId,
      dataHora: sessao.dataHora,
      numeroSessao: sessao.numeroSessao,
      status: sessao.status,
      statusPagamento: sessao.statusPagamento,
      dataPagamento: sessao.dataPagamento,
      observacoes: sessao.observacoes,
    );
  }
}

