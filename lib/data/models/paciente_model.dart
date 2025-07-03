import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/core/utils/date_formatter.dart'; // Importação adicionada

// Modelo de dados para a entidade Paciente, com métodos para serialização/desserialização do Firestore
class PacienteModel extends Paciente {
  PacienteModel({
    String? id,
    required String nome,
    required DateTime dataNascimento,
    required String nomeResponsavel,
    String? telefoneResponsavel,
    String? emailResponsavel,
    String? afinandoCerebro,
    String? observacoes,
    required DateTime dataCadastro,
    required String status,
  }) : super(
          id: id,
          nome: nome,
          dataNascimento: dataNascimento,
          nomeResponsavel: nomeResponsavel,
          telefoneResponsavel: telefoneResponsavel,
          emailResponsavel: emailResponsavel,
          afinandoCerebro: afinandoCerebro,
          observacoes: observacoes,
          dataCadastro: dataCadastro,
          status: status,
        );

  // Construtor para criar um PacienteModel a partir de um DocumentSnapshot do Firestore
  factory PacienteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PacienteModel(
      id: doc.id,
      nome: data['nome'] as String,
      // Converte a string 'dd/MM/yyyy' do Firestore para DateTime usando o DateFormatter
      dataNascimento: DateFormatter.parseDate(data['dataNascimento'] as String),
      nomeResponsavel: data['nomeResponsavel'] as String,
      telefoneResponsavel: data['telefoneResponsavel'] as String?,
      emailResponsavel: data['emailResponsavel'] as String?,
      afinandoCerebro: data['afinandoCerebro'] as String?,
      observacoes: data['observacoes'] as String?,
      dataCadastro: (data['dataCadastro'] as Timestamp).toDate(), // dataCadastro continua como Timestamp
      status: data['status'] as String,
    );
  }

  // Converte o PacienteModel para um mapa de dados compatível com o Firestore
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      // Converte DateTime para string 'dd/MM/yyyy' para o Firestore usando o DateFormatter
      'dataNascimento': DateFormatter.formatDate(dataNascimento),
      'nomeResponsavel': nomeResponsavel,
      'telefoneResponsavel': telefoneResponsavel,
      'emailResponsavel': emailResponsavel,
      'afinandoCerebro': afinandoCerebro,
      'observacoes': observacoes,
      'dataCadastro': Timestamp.fromDate(dataCadastro), // dataCadastro continua como Timestamp
      'status': status,
    };
  }

  // Construtor para criar um PacienteModel a partir de uma entidade Paciente
  factory PacienteModel.fromEntity(Paciente paciente) {
    return PacienteModel(
      id: paciente.id,
      nome: paciente.nome,
      dataNascimento: paciente.dataNascimento,
      nomeResponsavel: paciente.nomeResponsavel,
      telefoneResponsavel: paciente.telefoneResponsavel,
      emailResponsavel: paciente.emailResponsavel,
      afinandoCerebro: paciente.afinandoCerebro,
      observacoes: paciente.observacoes,
      dataCadastro: paciente.dataCadastro,
      status: paciente.status,
    );
  }
}
