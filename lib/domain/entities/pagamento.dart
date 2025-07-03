// Entidade pura de domínio para Pagamento
class Pagamento {
  final String? id; // ID do documento no Firestore
  final String treinamentoId;
  final String pacienteId;
  final String formaPagamento; // "Dinheiro", "Pix", "Convenio"
  final String? tipoParcelamento; // "Por sessão", "3x" (para Dinheiro/Pix)
  final String status; // "Pendente", "Realizado"
  final DateTime dataPagamento;
  final String? observacoes;
  final String? guiaConvenio; // Número da guia para convênio
  final DateTime? dataEnvioGuia; // Data de envio da guia para convênio

  Pagamento({
    this.id,
    required this.treinamentoId,
    required this.pacienteId,
    required this.formaPagamento,
    this.tipoParcelamento,
    required this.status,
    required this.dataPagamento,
    this.observacoes,
    this.guiaConvenio,
    this.dataEnvioGuia,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  Pagamento copyWith({
    String? id,
    String? treinamentoId,
    String? pacienteId,
    String? formaPagamento,
    String? tipoParcelamento,
    String? status,
    DateTime? dataPagamento,
    String? observacoes,
    String? guiaConvenio,
    DateTime? dataEnvioGuia,
  }) {
    return Pagamento(
      id: id ?? this.id,
      treinamentoId: treinamentoId ?? this.treinamentoId,
      pacienteId: pacienteId ?? this.pacienteId,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      tipoParcelamento: tipoParcelamento ?? this.tipoParcelamento,
      status: status ?? this.status,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      observacoes: observacoes ?? this.observacoes,
      guiaConvenio: guiaConvenio ?? this.guiaConvenio,
      dataEnvioGuia: dataEnvioGuia ?? this.dataEnvioGuia,
    );
  }
}

