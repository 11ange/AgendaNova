// Entidade pura de domínio para a Lista de Espera
class ListaEspera {
  final String? id; // ID do documento no Firestore
  final String? ownerId; // UID do profissional no Firebase Auth
  final String nome;
  final String? telefone;
  final String? observacoes;
  final DateTime dataCadastro;
  final String? tipoConvenio;
  final String status; // NOVO CAMPO: "aguardando" ou "saiu"

  ListaEspera({
    this.id,
    this.ownerId,
    required this.nome,
    this.telefone,
    this.observacoes,
    required this.dataCadastro,
    this.tipoConvenio,
    this.status = 'aguardando', // Valor padrão
  });

  // Método para criar uma cópia da entidade com campos atualizados
  ListaEspera copyWith({
    String? id,
    String? ownerId,
    String? nome,
    String? telefone,
    String? observacoes,
    DateTime? dataCadastro,
    String? tipoConvenio,
    String? status,
  }) {
    return ListaEspera(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      tipoConvenio: tipoConvenio ?? this.tipoConvenio,
      status: status ?? this.status,
    );
  }
}