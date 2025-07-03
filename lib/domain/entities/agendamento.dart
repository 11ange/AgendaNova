// Entidade pura de domínio para Agendamento
class Agendamento {
  final String? id; // ID do documento no Firestore
  final String pacienteId;
  final DateTime dataHora;
  final String tipo; // Ex: "Treinamento", "Sessao Avulsa", "Consulta"
  final String
  status; // Ex: "Agendado", "Realizado", "Cancelado", "Falta", "Bloqueado"
  final String? observacoes;

  Agendamento({
    this.id,
    required this.pacienteId,
    required this.dataHora,
    required this.tipo,
    required this.status,
    this.observacoes,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  Agendamento copyWith({
    String? id,
    String? pacienteId,
    DateTime? dataHora,
    String? tipo,
    String? status,
    String? observacoes,
  }) {
    return Agendamento(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      dataHora: dataHora ?? this.dataHora,
      tipo: tipo ?? this.tipo,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}