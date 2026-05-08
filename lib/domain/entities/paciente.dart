// Entidade pura de domínio Paciente
class Paciente {
  final String? id; // ID do documento no Firestore
  final String? ownerId; // UID do profissional no Firebase Auth
  final String nome;
  final DateTime dataNascimento;
  final String nomeResponsavel;
  final String? telefoneResponsavel;
  final String? emailResponsavel;
  final String? afinandoCerebro; // "Não enviado", "Enviado", "Cadastrado"
  final String? observacoes;
  final DateTime dataCadastro;
  final DateTime? dataArquivamento;
  final String status; // "ativo", "inativo" ou "arquivado"
  final String nomeBusca; // Nome normalizado para busca (lowercase, sem espaços extras)

  Paciente({
    this.id,
    this.ownerId,
    required this.nome,
    required this.dataNascimento,
    required this.nomeResponsavel,
    this.telefoneResponsavel,
    this.emailResponsavel,
    this.afinandoCerebro,
    this.observacoes,
    required this.dataCadastro,
    this.dataArquivamento,
    required this.status,
    String? nomeBusca,
  }) : nomeBusca = nomeBusca ?? normalizeName(nome);

  // Método estático para normalizar nomes de forma consistente em todo o app
  static String normalizeName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Método para calcular a idade do paciente
  int get idade {
    final now = DateTime.now();
    int age = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      age--;
    }
    return age;
  }

  // Método para criar uma cópia da entidade com campos atualizados
  Paciente copyWith({
    String? id,
    String? ownerId,
    String? nome,
    DateTime? dataNascimento,
    String? nomeResponsavel,
    String? telefoneResponsavel,
    String? emailResponsavel,
    String? afinandoCerebro,
    String? observacoes,
    DateTime? dataCadastro,
    DateTime? dataArquivamento,
    String? status,
    String? nomeBusca,
  }) {
    return Paciente(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
      telefoneResponsavel: telefoneResponsavel ?? this.telefoneResponsavel,
      emailResponsavel: emailResponsavel ?? this.emailResponsavel,
      afinandoCerebro: afinandoCerebro ?? this.afinandoCerebro,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataArquivamento: dataArquivamento ?? this.dataArquivamento,
      status: status ?? this.status,
      nomeBusca: nomeBusca ?? this.nomeBusca,
    );
  }

  // --- CORREÇÃO AQUI: Implementação de igualdade e hashCode ---
  // Isto ensina o Dart a considerar dois pacientes como iguais se os seus IDs forem iguais.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Paciente && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}