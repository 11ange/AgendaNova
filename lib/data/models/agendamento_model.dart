import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/agendamento.dart'; // Importação da entidade Agendamento

// Modelo de dados para a entidade Agendamento, com métodos para serialização/desserialização do Firestore
class AgendamentoModel extends Agendamento {
  AgendamentoModel({
    String? id,
    required String pacienteId,
    required DateTime dataHora,
    required String tipo,
    required String status,
    String? observacoes,
  }) : super(
          id: id,
          pacienteId: pacienteId,
          dataHora: dataHora,
          tipo: tipo,
          status: status,
          observacoes: observacoes,
        );

  // Construtor para criar um AgendamentoModel a partir de um DocumentSnapshot do Firestore
  factory AgendamentoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgendamentoModel(
      id: doc.id,
      pacienteId: data['pacienteId'] as String,
      dataHora: (data['dataHora'] as Timestamp).toDate(),
      tipo: data['tipo'] as String,
      status: data['status'] as String,
      observacoes: data['observacoes'] as String?,
    );
  }

  // Converte o AgendamentoModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pacienteId': pacienteId,
      'dataHora': Timestamp.fromDate(dataHora),
      'tipo': tipo,
      'status': status,
      'observacoes': observacoes,
    };
  }

  // Construtor para criar um AgendamentoModel a partir de uma entidade Agendamento
  factory AgendamentoModel.fromEntity(Agendamento agendamento) {
    return AgendamentoModel(
      id: agendamento.id,
      pacienteId: agendamento.pacienteId,
      dataHora: agendamento.dataHora,
      tipo: agendamento.tipo,
      status: agendamento.status,
      observacoes: agendamento.observacoes,
    );
  }
}

