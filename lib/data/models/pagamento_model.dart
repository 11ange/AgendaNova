import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/pagamento.dart';

// Modelo de dados para a entidade Pagamento, com métodos para serialização/desserialização do Firestore
class PagamentoModel extends Pagamento {
  PagamentoModel({
    super.id,
    required super.treinamentoId,
    required super.pacienteId,
    required super.formaPagamento,
    super.tipoParcelamento,
    required super.status,
    required super.dataPagamento,
    super.observacoes,
    super.guiaConvenio,
    super.dataEnvioGuia,
  });

  // Construtor para criar um PagamentoModel a partir de um DocumentSnapshot do Firestore
  factory PagamentoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PagamentoModel(
      id: doc.id,
      treinamentoId: data['treinamentoId'] as String,
      pacienteId: data['pacienteId'] as String,
      formaPagamento: data['formaPagamento'] as String,
      tipoParcelamento: data['tipoParcelamento'] as String?,
      status: data['status'] as String,
      dataPagamento: (data['dataPagamento'] as Timestamp).toDate(),
      observacoes: data['observacoes'] as String?,
      guiaConvenio: data['guiaConvenio'] as String?,
      dataEnvioGuia: (data['dataEnvioGuia'] as Timestamp?)?.toDate(),
    );
  }

  // Converte o PagamentoModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'treinamentoId': treinamentoId,
      'pacienteId': pacienteId,
      'formaPagamento': formaPagamento,
      'tipoParcelamento': tipoParcelamento,
      'status': status,
      'dataPagamento': Timestamp.fromDate(dataPagamento),
      'observacoes': observacoes,
      'guiaConvenio': guiaConvenio,
      'dataEnvioGuia': dataEnvioGuia != null
          ? Timestamp.fromDate(dataEnvioGuia!)
          : null,
    };
  }

  // Construtor para criar um PagamentoModel a partir de uma entidade Pagamento
  factory PagamentoModel.fromEntity(Pagamento pagamento) {
    return PagamentoModel(
      id: pagamento.id,
      treinamentoId: pagamento.treinamentoId,
      pacienteId: pagamento.pacienteId,
      formaPagamento: pagamento.formaPagamento,
      tipoParcelamento: pagamento.tipoParcelamento,
      status: pagamento.status,
      dataPagamento: pagamento.dataPagamento,
      observacoes: pagamento.observacoes,
      guiaConvenio: pagamento.guiaConvenio,
      dataEnvioGuia: pagamento.dataEnvioGuia,
    );
  }
}
