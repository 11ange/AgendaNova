import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_agenda_fono/domain/entities/treinamento.dart';

// Modelo de dados para a entidade Treinamento, com métodos para serialização/desserialização do Firestore
class TreinamentoModel extends Treinamento {
  TreinamentoModel({
    String? id,
    required String pacienteId,
    required String diaSemana,
    required String horario,
    required int numeroSessoesTotal,
    required DateTime dataInicio,
    required DateTime dataFimPrevista,
    required String status,
    required String formaPagamento,
    String? tipoParcelamento,
    required DateTime dataCadastro,
  }) : super(
          id: id,
          pacienteId: pacienteId,
          diaSemana: diaSemana,
          horario: horario,
          numeroSessoesTotal: numeroSessoesTotal,
          dataInicio: dataInicio,
          dataFimPrevista: dataFimPrevista,
          status: status,
          formaPagamento: formaPagamento,
          tipoParcelamento: tipoParcelamento,
          dataCadastro: dataCadastro,
        );

  // Construtor para criar um TreinamentoModel a partir de um DocumentSnapshot do Firestore
  factory TreinamentoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TreinamentoModel(
      id: doc.id,
      pacienteId: data['pacienteId'] as String,
      diaSemana: data['diaSemana'] as String,
      horario: data['horario'] as String,
      numeroSessoesTotal: data['numeroSessoesTotal'] as int,
      dataInicio: (data['dataInicio'] as Timestamp).toDate(),
      dataFimPrevista: (data['dataFimPrevista'] as Timestamp).toDate(),
      status: data['status'] as String,
      formaPagamento: data['formaPagamento'] as String,
      tipoParcelamento: data['tipoParcelamento'] as String?,
      dataCadastro: (data['dataCadastro'] as Timestamp).toDate(),
    );
  }

  // Converte o TreinamentoModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pacienteId': pacienteId,
      'diaSemana': diaSemana,
      'horario': horario,
      'numeroSessoesTotal': numeroSessoesTotal,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFimPrevista': Timestamp.fromDate(dataFimPrevista),
      'status': status,
      'formaPagamento': formaPagamento,
      'tipoParcelamento': tipoParcelamento,
      'dataCadastro': Timestamp.fromDate(dataCadastro),
    };
  }

  // Construtor para criar um TreinamentoModel a partir de uma entidade Treinamento
  factory TreinamentoModel.fromEntity(Treinamento treinamento) {
    return TreinamentoModel(
      id: treinamento.id,
      pacienteId: treinamento.pacienteId,
      diaSemana: treinamento.diaSemana,
      horario: treinamento.horario,
      numeroSessoesTotal: treinamento.numeroSessoesTotal,
      dataInicio: treinamento.dataInicio,
      dataFimPrevista: treinamento.dataFimPrevista,
      status: treinamento.status,
      formaPagamento: treinamento.formaPagamento,
      tipoParcelamento: treinamento.tipoParcelamento,
      dataCadastro: treinamento.dataCadastro,
    );
  }
}

