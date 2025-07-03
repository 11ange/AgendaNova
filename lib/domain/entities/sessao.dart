// Entidade pura de domínio para Sessão
class Sessao {
  final String? id; // ID do documento no Firestore (será o ID da sub-sessão, se aplicável, ou gerado)
  final String treinamentoId;
  final String pacienteId;
  final String pacienteNome; // Novo campo
  final DateTime dataHora;
  final int numeroSessao; // Número da sessão dentro do treinamento (ex: 1 de 10)
  final String status; // "Agendada", "Realizada", "Falta", "Cancelada", "Bloqueada"
  final String statusPagamento; // "Pendente", "Realizado"
  final DateTime? dataPagamento;
  final String? observacoes;
  final String formaPagamento; // Novo campo
  final DateTime agendamentoStartDate; // Novo campo
  final String? parcelamento; // Novo campo
  final Map<String, dynamic>? pagamentosParcelados; // Novo campo (mapa aninhado)
  final bool? reagendada; // Novo campo
  final int totalSessoes; // Novo campo

  Sessao({
    this.id,
    required this.treinamentoId,
    required this.pacienteId,
    required this.pacienteNome,
    required this.dataHora,
    required this.numeroSessao,
    required this.status,
    required this.statusPagamento,
    this.dataPagamento,
    this.observacoes,
    required this.formaPagamento,
    required this.agendamentoStartDate,
    this.parcelamento,
    this.pagamentosParcelados,
    this.reagendada,
    required this.totalSessoes,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  Sessao copyWith({
    String? id,
    String? treinamentoId,
    String? pacienteId,
    String? pacienteNome,
    DateTime? dataHora,
    int? numeroSessao,
    String? status,
    String? statusPagamento,
    DateTime? dataPagamento,
    String? observacoes,
    String? formaPagamento,
    DateTime? agendamentoStartDate,
    String? parcelamento,
    Map<String, dynamic>? pagamentosParcelados,
    bool? reagendada,
    int? totalSessoes,
  }) {
    return Sessao(
      id: id ?? this.id,
      treinamentoId: treinamentoId ?? this.treinamentoId,
      pacienteId: pacienteId ?? this.pacienteId,
      pacienteNome: pacienteNome ?? this.pacienteNome,
      dataHora: dataHora ?? this.dataHora,
      numeroSessao: numeroSessao ?? this.numeroSessao,
      status: status ?? this.status,
      statusPagamento: statusPagamento ?? this.statusPagamento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      observacoes: observacoes ?? this.observacoes,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      agendamentoStartDate: agendamentoStartDate ?? this.agendamentoStartDate,
      parcelamento: parcelamento ?? this.parcelamento,
      pagamentosParcelados: pagamentosParcelados ?? this.pagamentosParcelados,
      reagendada: reagendada ?? this.reagendada,
      totalSessoes: totalSessoes ?? this.totalSessoes,
    );
  }
}

