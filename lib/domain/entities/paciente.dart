// Entidade pura de domínio Paciente
class Paciente {
  final String? id; // ID do documento no Firestore
  final String nome;
  final DateTime dataNascimento;
  final String nomeResponsavel;
  final String? telefoneResponsavel;
  final String? emailResponsavel;
  final String? afinandoCerebro; // "Não enviado", "Enviado", "Cadastrado"
  final String? observacoes;
  final DateTime dataCadastro;
  final String status; // "ativo" ou "inativo"

  Paciente({
    this.id,
    required this.nome,
    required this.dataNascimento,
    required this.nomeResponsavel,
    this.telefoneResponsavel,
    this.emailResponsavel,
    this.afinandoCerebro,
    this.observacoes,
    required this.dataCadastro,
    required this.status,
  });

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
    String? nome,
    DateTime? dataNascimento,
    String? nomeResponsavel,
    String? telefoneResponsavel,
    String? emailResponsavel,
    String? afinandoCerebro,
    String? observacoes,
    DateTime? dataCadastro,
    String? status,
  }) {
    return Paciente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
      telefoneResponsavel: telefoneResponsavel ?? this.telefoneResponsavel,
      emailResponsavel: emailResponsavel ?? this.emailResponsavel,
      afinandoCerebro: afinandoCerebro ?? this.afinandoCerebro,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      status: status ?? this.status,
    );
  }
}
