import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/treinamento.dart';

// Modelo de dados para a entidade Treinamento, com métodos para serialização/desserialização do Firestore
class TreinamentoModel extends Treinamento {
  TreinamentoModel({
    super.id,
    required super.pacienteId,
    required super.diaSemana,
    required super.horario,
    required super.numeroSessoesTotal,
    required super.dataInicio,
    required super.dataFimPrevista,
    required super.status,
    required super.formaPagamento,
    super.tipoParcelamento,
    super.nomeConvenio,
    required super.dataCadastro,
  });

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
      nomeConvenio: data['nomeConvenio'] as String?, // --- NOVO CAMPO ---
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
      'nomeConvenio': nomeConvenio, // --- NOVO CAMPO ---
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
      nomeConvenio: treinamento.nomeConvenio, // --- NOVO CAMPO ---
      dataCadastro: treinamento.dataCadastro,
    );
  }
}
