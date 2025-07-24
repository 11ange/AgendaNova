import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:intl/intl.dart';

// Modelo de dados para a entidade Sessão, com métodos para serialização/desserialização do Firestore
class SessaoModel extends Sessao {
  SessaoModel({
    super.id,
    required super.treinamentoId,
    required super.pacienteId,
    required super.pacienteNome,
    required super.dataHora,
    required super.numeroSessao,
    required super.status,
    required super.statusPagamento,
    super.dataPagamento,
    super.observacoes,
    required super.formaPagamento,
    required super.agendamentoStartDate,
    super.parcelamento,
    super.pagamentosParcelados,
    super.reagendada,
    required super.totalSessoes,
  });

  // Construtor: para criar SessaoModel a partir de um mapa de dados de uma sub-sessão
  factory SessaoModel.fromMap(String docId, Map<String, dynamic> map, String horarioKey) {
    // Constrói a dataHora combinando o docId (yyyy-MM-dd) e horarioKey (HH:mm)
    final String dateTimeString = '$docId $horarioKey';
    final DateTime parsedDataHora = DateFormat('yyyy-MM-dd HH:mm').parse(dateTimeString);

    // Verifique se é uma sessão de bloqueio manual simplificada
    if (map['treinamentoId'] == 'bloqueio_manual' && map['status'] == 'Bloqueada') {
      return SessaoModel(
        id: '$docId-$horarioKey',
        treinamentoId: 'bloqueio_manual',
        pacienteId: 'bloqueio_manual',
        pacienteNome: 'Horário Bloqueado',
        dataHora: parsedDataHora,
        numeroSessao: 0,
        status: 'Bloqueada',
        statusPagamento: 'N/A',
        dataPagamento: null,
        observacoes: map['observacoes'] as String?,
        formaPagamento: 'N/A',
        agendamentoStartDate: parsedDataHora,
        parcelamento: null,
        pagamentosParcelados: null,
        reagendada: false,
        totalSessoes: 0,
      );
    }

    return SessaoModel(
      id: '$docId-$horarioKey',
      treinamentoId: map['agendamentoId'] as String? ?? '',
      pacienteId: map['pacienteId'] as String? ?? '',
      pacienteNome: map['pacienteNome'] as String? ?? 'Desconhecido',
      dataHora: parsedDataHora,
      numeroSessao: (map['sessaoNumero'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'Agendada',
      statusPagamento: map['statusPagamento'] as String? ?? 'Pendente',
      dataPagamento: (map['dataPagamento'] as Timestamp?)?.toDate(),
      observacoes: map['observacoes'] as String?,
      formaPagamento: map['formaPagamento'] as String? ?? 'Desconhecida',
      agendamentoStartDate: (map['agendamentoStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parcelamento: map['parcelamento'] as String?,
      pagamentosParcelados: map['pagamentosParcelados'] as Map<String, dynamic>?,
      reagendada: map['reagendada'] as bool? ?? false,
      totalSessoes: (map['totalSessoes'] as num?)?.toInt() ?? 0,
    );
  }

  // Converte o SessaoModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    // Se for uma sessão de bloqueio manual, retorna a representação simplificada
    if (treinamentoId == 'bloqueio_manual' && status == 'Bloqueada') {
      return {
        'status': 'Bloqueada',
        'treinamentoId': 'bloqueio_manual',
        'observacoes': observacoes, // Manter observações se houver
      };
    }

    // Para sessões normais, retorna o mapa completo
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
