// Entidade pura de domínio para a Disponibilidade de Horários
class AgendaDisponibilidade {
  final String? id; // O ID do documento no Firestore (geralmente um ID fixo ou do usuário)
  final String? ownerId; // UID do profissional no Firebase Auth
  final Map<String, List<String>> agenda; // Ex: {"Segunda-feira": ["14:30", "15:00"], ...}

  AgendaDisponibilidade({
    this.id,
    this.ownerId,
    required this.agenda,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  AgendaDisponibilidade copyWith({
    String? id,
    String? ownerId,
    Map<String, List<String>>? agenda,
  }) {
    return AgendaDisponibilidade(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      agenda: agenda ?? this.agenda,
    );
  }
}

