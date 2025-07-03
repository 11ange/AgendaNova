import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_agenda_fono/domain/entities/agenda_disponibilidade.dart';

// Modelo de dados para a entidade AgendaDisponibilidade, com métodos para serialização/desserialização do Firestore
class AgendaDisponibilidadeModel extends AgendaDisponibilidade {
  AgendaDisponibilidadeModel({
    String? id,
    required Map<String, List<String>> agenda,
  }) : super(
          id: id,
          agenda: agenda,
        );

  // Construtor para criar um AgendaDisponibilidadeModel a partir de um DocumentSnapshot do Firestore
  factory AgendaDisponibilidadeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Map<String, List<String>> agendaMap = {};
    (data['agenda'] as Map<String, dynamic>).forEach((key, value) {
      agendaMap[key] = List<String>.from(value);
    });

    return AgendaDisponibilidadeModel(
      id: doc.id,
      agenda: agendaMap,
    );
  }

  // Converte o AgendaDisponibilidadeModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'agenda': agenda,
    };
  }

  // Construtor para criar um AgendaDisponibilidadeModel a partir de uma entidade AgendaDisponibilidade
  factory AgendaDisponibilidadeModel.fromEntity(AgendaDisponibilidade agendaDisponibilidade) {
    return AgendaDisponibilidadeModel(
      id: agendaDisponibilidade.id,
      agenda: agendaDisponibilidade.agenda,
    );
  }
}

