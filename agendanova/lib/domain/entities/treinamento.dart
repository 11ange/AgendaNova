import 'package:agendanova/domain/entities/paciente.dart';

// Entidade pura de domínio para Treinamento
class Treinamento {
  final String? id; // ID do documento no Firestore
  final String pacienteId;
  final String diaSemana; // Ex: "Segunda-feira"
  final String horario; // Ex: "14:30"
  final int numeroSessoesTotal;
  final DateTime dataInicio;
  final DateTime dataFimPrevista; // Data da última sessão prevista
  final String status; // Ex: "ativo", "concluido", "cancelado"
  final String formaPagamento; // "Dinheiro", "Pix", "Convenio"
  final String? tipoParcelamento; // "Por sessão", "3x" (para Dinheiro/Pix)
  final DateTime dataCadastro;

  Treinamento({
    this.id,
    required this.pacienteId,
    required this.diaSemana,
    required this.horario,
    required this.numeroSessoesTotal,
    required this.dataInicio,
    required this.dataFimPrevista,
    required this.status,
    required this.formaPagamento,
    this.tipoParcelamento,
    required this.dataCadastro,
  });

  // Método para criar uma cópia da entidade com campos atualizados
  Treinamento copyWith({
    String? id,
    String? pacienteId,
    String? diaSemana,
    String? horario,
    int? numeroSessoesTotal,
    DateTime? dataInicio,
    DateTime? dataFimPrevista,
    String? status,
    String? formaPagamento,
    String? tipoParcelamento,
    DateTime? dataCadastro,
  }) {
    return Treinamento(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      diaSemana: diaSemana ?? this.diaSemana,
      horario: horario ?? this.horario,
      numeroSessoesTotal: numeroSessoesTotal ?? this.numeroSessoesTotal,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFimPrevista: dataFimPrevista ?? this.dataFimPrevista,
      status: status ?? this.status,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      tipoParcelamento: tipoParcelamento ?? this.tipoParcelamento,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }
}

