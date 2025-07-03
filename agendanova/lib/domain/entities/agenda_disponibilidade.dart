// Entidade pura de domínio para a Disponibilidade de Horários
class AgendaDisponibilidade {
  final String? id; // O ID do documento no Firestore (geralmente um ID fixo ou do usuário)
  final Map<String, List<String>> agenda; // Ex: {"Segunda-feira": ["14:30", "15:00"], ...}

  AgendaDisponibilidade({
    this.id,
    required this.agenda,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  AgendaDisponibilidade copyWith({
    String? id,
    Map<String, List<String>>? agenda,
  }) {
    return AgendaDisponibilidade(
      id: id ?? this.id,
      agenda: agenda ?? this.agenda,
    );
  }
}

