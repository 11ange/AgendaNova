import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/sessao.dart'; // Importação da entidade Sessao
import 'package:intl/intl.dart'; // Para DateFormat

// Modelo de dados para a entidade Sessão, com métodos para serialização/desserialização do Firestore
class SessaoModel extends Sessao {
  SessaoModel({
    String? id,
    required String treinamentoId,
    required String pacienteId,
    required String pacienteNome,
    required DateTime dataHora,
    required int numeroSessao,
    required String status,
    required String statusPagamento,
    DateTime? dataPagamento,
    String? observacoes,
    required String formaPagamento,
    required DateTime agendamentoStartDate,
    String? parcelamento,
    Map<String, dynamic>? pagamentosParcelados,
    bool? reagendada,
    required int totalSessoes,
  }) : super(
          id: id,
          treinamentoId: treinamentoId,
          pacienteId: pacienteId,
          pacienteNome: pacienteNome,
          dataHora: dataHora,
          numeroSessao: numeroSessao,
          status: status,
          statusPagamento: statusPagamento,
          dataPagamento: dataPagamento,
          observacoes: observacoes,
          formaPagamento: formaPagamento,
          agendamentoStartDate: agendamentoStartDate,
          parcelamento: parcelamento,
          pagamentosParcelados: pagamentosParcelados,
          reagendada: reagendada,
          totalSessoes: totalSessoes,
        );

  // Construtor: para criar SessaoModel a partir de um mapa de dados de uma sub-sessão
  factory SessaoModel.fromMap(String docId, Map<String, dynamic> map, String horarioKey) {
    // Constrói a dataHora combinando o docId (yyyy-MM-dd) e horarioKey (HH:mm)
    final String dateTimeString = '$docId $horarioKey';
    final DateTime parsedDataHora = DateFormat('yyyy-MM-dd HH:mm').parse(dateTimeString);

    return SessaoModel(
      id: '${docId}-${horarioKey.replaceAll(':', '')}', // ID combinado para referência
      treinamentoId: map['agendamentoId'] as String? ?? '', // Fornece fallback se nulo/ausente
      pacienteId: map['pacienteId'] as String? ?? '', // Fornece fallback se nulo/ausente
      pacienteNome: map['pacienteNome'] as String? ?? 'Desconhecido', // Fornece fallback se nulo/ausente
      dataHora: parsedDataHora,
      numeroSessao: (map['sessaoNumero'] as num?)?.toInt() ?? 0, // Fornece fallback se nulo/ausente
      status: map['status'] as String? ?? 'Agendada', // Fornece fallback se nulo/ausente
      statusPagamento: map['statusPagamento'] as String? ?? 'Pendente', // Fornece fallback se nulo/ausente
      dataPagamento: (map['dataPagamento'] as Timestamp?)?.toDate(),
      observacoes: map['observacoes'] as String?,
      formaPagamento: map['formaPagamento'] as String? ?? 'Desconhecida', // Fornece fallback se nulo/ausente
      agendamentoStartDate: (map['agendamentoStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(), // Fornece fallback se nulo/ausente
      parcelamento: map['parcelamento'] as String?,
      pagamentosParcelados: map['pagamentosParcelados'] as Map<String, dynamic>?,
      reagendada: map['reagendada'] as bool? ?? false, // Fornece fallback se nulo/ausente
      totalSessoes: (map['totalSessoes'] as num?)?.toInt() ?? 0, // Fornece fallback se nulo/ausente
    );
  }

  // Converte o SessaoModel para um mapa de dados compatível com o Firestore
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'agendamentoId': treinamentoId,
      'pacienteId': pacienteId,
      'pacienteNome': pacienteNome,
      'sessaoNumero': numeroSessao,
      'status': status,
      'statusPagamento': statusPagamento,
      'dataPagamento': dataPagamento != null ? Timestamp.fromDate(dataPagamento!) : null,
      'observacoes': observacoes,
      'formaPagamento': formaPagamento,
      'agendamentoStartDate': Timestamp.fromDate(agendamentoStartDate),
      'parcelamento': parcelamento,
      'pagamentosParcelados': pagamentosParcelados,
      'reagendada': reagendada,
      'totalSessoes': totalSessoes,
    };
  }

  // Construtor para criar um SessaoModel a partir de uma entidade Sessao
  factory SessaoModel.fromEntity(Sessao sessao) {
    return SessaoModel(
      id: sessao.id,
      treinamentoId: sessao.treinamentoId,
      pacienteId: sessao.pacienteId,
      pacienteNome: sessao.pacienteNome,
      dataHora: sessao.dataHora,
      numeroSessao: sessao.numeroSessao,
      status: sessao.status,
      statusPagamento: sessao.statusPagamento,
      dataPagamento: sessao.dataPagamento,
      observacoes: sessao.observacoes,
      formaPagamento: sessao.formaPagamento,
      agendamentoStartDate: sessao.agendamentoStartDate,
      parcelamento: sessao.parcelamento,
      pagamentosParcelados: sessao.pagamentosParcelados,
      reagendada: sessao.reagendada,
      totalSessoes: sessao.totalSessoes,
    );
  }
}
