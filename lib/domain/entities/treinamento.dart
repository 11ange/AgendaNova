// 11ange/agendanova/AgendaNova-9b6192d7a5af5a265ec3aa3d41748ca9d26ac96a/lib/domain/entities/treinamento.dart
import 'package:agenda_treinamento/domain/entities/pagamento.dart';

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
  final String? nomeConvenio; // --- NOVO CAMPO ---
  final DateTime dataCadastro;
  final List<Pagamento>? pagamentos;

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
    this.nomeConvenio, // --- NOVO CAMPO ---
    required this.dataCadastro,
    this.pagamentos,
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
    String? nomeConvenio, // --- NOVO CAMPO ---
    DateTime? dataCadastro,
    List<Pagamento>? pagamentos,
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
      nomeConvenio: nomeConvenio ?? this.nomeConvenio, // --- NOVO CAMPO ---
      dataCadastro: dataCadastro ?? this.dataCadastro,
      pagamentos: pagamentos ?? this.pagamentos,
    );
  }
}