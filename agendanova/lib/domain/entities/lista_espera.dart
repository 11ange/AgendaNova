// Entidade pura de domínio para a Lista de Espera
class ListaEspera {
  final String? id; // ID do documento no Firestore
  final String nome;
  final String? telefone;
  final String? observacoes;
  final DateTime dataCadastro;

  ListaEspera({
    this.id,
    required this.nome,
    this.telefone,
    this.observacoes,
    required this.dataCadastro,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  ListaEspera copyWith({
    String? id,
    String? nome,
    String? telefone,
    String? observacoes,
    DateTime? dataCadastro,
  }) {
    return ListaEspera(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }
}

