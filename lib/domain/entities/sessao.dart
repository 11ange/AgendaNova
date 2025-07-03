// Entidade pura de domínio para Sessão
class Sessao {
  final String? id; // ID do documento no Firestore
  final String treinamentoId;
  final String pacienteId;
  final DateTime dataHora;
  final int numeroSessao; // Número da sessão dentro do treinamento (ex: 1 de 10)
  final String status; // "Agendada", "Realizada", "Falta", "Cancelada", "Bloqueada"
  final String statusPagamento; // "Pendente", "Realizado"
  final DateTime? dataPagamento;
  final String? observacoes;

  Sessao({
    this.id,
    required this.treinamentoId,
    required this.pacienteId,
    required this.dataHora,
    required this.numeroSessao,
    required this.status,
    required this.statusPagamento,
    this.dataPagamento,
    this.observacoes,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  Sessao copyWith({
    String? id,
    String? treinamentoId,
    String? pacienteId,
    DateTime? dataHora,
    int? numeroSessao,
    String? status,
    String? statusPagamento,
    DateTime? dataPagamento,
    String? observacoes,
  }) {
    return Sessao(
      id: id ?? this.id,
      treinamentoId: treinamentoId ?? this.treinamentoId,
      pacienteId: pacienteId ?? this.pacienteId,
      dataHora: dataHora ?? this.dataHora,
      numeroSessao: numeroSessao ?? this.numeroSessao,
      status: status ?? this.status,
      statusPagamento: statusPagamento ?? this.statusPagamento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}

