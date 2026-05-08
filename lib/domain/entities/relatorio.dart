// Entidade pura de domínio para Relatório (representa um resumo de dados para relatórios)
class Relatorio {
  final String id; // Pode ser um ID gerado ou baseado no tipo de relatório/período
  final String? ownerId; // UID do profissional no Firebase Auth
  final String tipoRelatorio; // Ex: "Mensal Global", "Individual Paciente"
  final DateTime dataGeracao;
  final Map<String, dynamic> dados; // Dados específicos do relatório (flexível)

  Relatorio({
    required this.id,
    this.ownerId,
    required this.tipoRelatorio,
    required this.dataGeracao,
    required this.dados,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  Relatorio copyWith({
    String? id,
    String? ownerId,
    String? tipoRelatorio,
    DateTime? dataGeracao,
    Map<String, dynamic>? dados,
  }) {
    return Relatorio(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      tipoRelatorio: tipoRelatorio ?? this.tipoRelatorio,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      dados: dados ?? this.dados,
    );
  }
}

