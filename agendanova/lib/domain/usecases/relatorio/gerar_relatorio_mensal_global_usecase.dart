import 'package:flutter_agenda_fono/domain/entities/relatorio.dart';
import 'package:flutter_agenda_fono/domain/repositories/sessao_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/treinamento_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/paciente_repository.dart';

// Use case para gerar o relatório mensal global das sessões
class GerarRelatorioMensalGlobalUseCase {
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final PacienteRepository _pacienteRepository;

  GerarRelatorioMensalGlobalUseCase(
    this._sessaoRepository,
    this._treinamentoRepository,
    this._pacienteRepository,
  );

  Future<Relatorio> call(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1, 0, 0, 0);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59); // Último dia do mês

    // Obter todas as sessões dentro do período do mês
    final allSessoes = await _sessaoRepository.getSessoes().first; // Obter todas as sessões
    final sessoesNoMes = allSessoes.where((sessao) {
      return sessao.dataHora.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             sessao.dataHora.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    // Obter todos os treinamentos e pacientes para referência
    final allTreinamentos = await _treinamentoRepository.getTreinamentos().first;
    final allPacientes = await _pacienteRepository.getPacientes().first;

    // Calcular resumo de ocupação
    int sessoesRealizadas = 0;
    int sessoesFalta = 0;
    int sessoesCanceladas = 0;
    int sessoesBloqueadas = 0;
    int sessoesAgendadas = 0;

    for (var sessao in sessoesNoMes) {
      switch (sessao.status) {
        case 'Realizada':
          sessoesRealizadas++;
          break;
        case 'Falta':
          sessoesFalta++;
          break;
        case 'Cancelada':
          sessoesCanceladas++;
          break;
        case 'Bloqueada':
          sessoesBloqueadas++;
          break;
        case 'Agendada':
          sessoesAgendadas++;
          break;
      }
    }

    // Você pode adicionar mais métricas aqui, como:
    // - Total de horas de atendimento
    // - Receita total (se houver integração com pagamentos)
    // - Pacientes mais ativos/inativos

    final dadosRelatorio = {
      'mes': month,
      'ano': year,
      'totalSessoesNoMes': sessoesNoMes.length,
      'sessoesRealizadas': sessoesRealizadas,
      'sessoesFalta': sessoesFalta,
      'sessoesCanceladas': sessoesCanceladas,
      'sessoesBloqueadas': sessoesBloqueadas,
      'sessoesAgendadas': sessoesAgendadas,
      // Detalhes das sessões (opcional, pode ser muito grande para o relatório)
      'detalhesSessoes': sessoesNoMes.map((s) {
        final paciente = allPacientes.firstWhere((p) => p.id == s.pacienteId, orElse: () => throw Exception('Paciente não encontrado'));
        final treinamento = allTreinamentos.firstWhere((t) => t.id == s.treinamentoId, orElse: () => throw Exception('Treinamento não encontrado'));
        return {
          'dataHora': s.dataHora.toIso8601String(),
          'pacienteNome': paciente.nome,
          'treinamentoHorario': '${treinamento.diaSemana} ${treinamento.horario}',
          'status': s.status,
          'statusPagamento': s.statusPagamento,
        };
      }).toList(),
    };

    return Relatorio(
      id: 'mensal_global_${year}_${month}',
      tipoRelatorio: 'Mensal Global',
      dataGeracao: DateTime.now(),
      dados: dadosRelatorio,
    );
  }
}

