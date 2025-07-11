import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';

// Modelo de dados para a entidade AgendaDisponibilidade, com métodos para serialização/desserialização do Firestore
class AgendaDisponibilidadeModel extends AgendaDisponibilidade {
  AgendaDisponibilidadeModel({
    super.id,
    required super.agenda,
  });

  // Construtor para criar um AgendaDisponibilidadeModel a partir de um DocumentSnapshot do Firestore
  factory AgendaDisponibilidadeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Map<String, List<String>> agendaMap = {};
    // Acessa os dias da semana diretamente na raiz do documento
    data.forEach((key, value) {
      // Filtra para incluir apenas os dias da semana esperados
      if (['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'].contains(key)) {
        agendaMap[key] = List<String>.from(value);
      }
    });

    return AgendaDisponibilidadeModel(
      id: doc.id,
      agenda: agendaMap,
    );
  }

  // Converte o AgendaDisponibilidadeModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    // Salva o mapa da agenda diretamente na raiz do documento
    return agenda;
  }

  // Construtor para criar um AgendaDisponibilidadeModel a partir de uma entidade AgendaDisponibilidade
  factory AgendaDisponibilidadeModel.fromEntity(AgendaDisponibilidade agendaDisponibilidade) {
    return AgendaDisponibilidadeModel(
      id: agendaDisponibilidade.id,
      agenda: agendaDisponibilidade.agenda,
    );
  }
}
