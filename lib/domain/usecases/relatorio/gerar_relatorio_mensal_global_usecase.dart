import 'package:agenda_treinamento/domain/entities/relatorio.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';

class GerarRelatorioMensalGlobalUseCase {
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final PacienteRepository _pacienteRepository; // Mantido no construtor para não quebrar dependências existentes

  GerarRelatorioMensalGlobalUseCase(
    this._sessaoRepository,
    this._treinamentoRepository,
    this._pacienteRepository,
  );

  Future<Relatorio> call(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1, 0, 0, 0);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final allSessoes = await _sessaoRepository.getSessoes().first;
    final sessoesNoMes = allSessoes.where((sessao) {
      return sessao.dataHora.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             sessao.dataHora.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    // Obter todos os treinamentos
    final allTreinamentos = await _treinamentoRepository.getTreinamentos().first;

    int sessoesRealizadas = 0;
    int sessoesFalta = 0;
    int sessoesCanceladas = 0;
    int sessoesBloqueadas = 0;
    int sessoesAgendadas = 0;

    for (var sessao in sessoesNoMes) {
      switch (sessao.status) {
        case 'Realizada': sessoesRealizadas++; break;
        case 'Falta': sessoesFalta++; break;
        case 'Cancelada': sessoesCanceladas++; break;
        case 'Bloqueada': sessoesBloqueadas++; break;
        case 'Agendada': sessoesAgendadas++; break;
      }
    }

    // Lógica para Treinamentos Iniciados e Finalizados por Forma de Pagamento
    Map<String, int> iniciadosPorPagamento = {};
    Map<String, int> finalizadosPorPagamento = {};

    for (var treinamento in allTreinamentos) {
      String pagamento = treinamento.formaPagamento; // Ex: Pix, Dinheiro, Convenio

      // Checa se INICIOU no mês
      if (treinamento.dataInicio.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          treinamento.dataInicio.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        iniciadosPorPagamento[pagamento] = (iniciadosPorPagamento[pagamento] ?? 0) + 1;
      }

      // Checa se FINALIZOU no mês (usando a dataFimPrevista)
      if (treinamento.dataFimPrevista.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          treinamento.dataFimPrevista.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        finalizadosPorPagamento[pagamento] = (finalizadosPorPagamento[pagamento] ?? 0) + 1;
      }
    }

    final dadosRelatorio = {
      'Mês': month,
      'Ano': year,
      'Total de Sessões no Mês': sessoesNoMes.length,
      'Sessões Realizadas': sessoesRealizadas,
      'Sessões Falta': sessoesFalta,
      'Sessões Canceladas': sessoesCanceladas,
      'Sessões Bloqueadas': sessoesBloqueadas,
      'Sessões Agendadas': sessoesAgendadas,
      'Treinamentos Iniciados no mês': iniciadosPorPagamento.isEmpty ? {'Nenhum': 0} : iniciadosPorPagamento,
      'Treinamentos Finalizados no mês': finalizadosPorPagamento.isEmpty ? {'Nenhum': 0} : finalizadosPorPagamento,
    };

    return Relatorio(
      id: 'mensal_global_${year}_$month',
      tipoRelatorio: 'Mensal Global',
      dataGeracao: DateTime.now(),
      dados: dadosRelatorio,
    );
  }
}