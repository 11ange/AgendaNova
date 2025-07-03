import 'package:agendanova/domain/entities/relatorio.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';

// Use case para gerar o relatório individual de um paciente
class GerarRelatorioIndividualPacienteUseCase {
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final PacienteRepository _pacienteRepository;

  GerarRelatorioIndividualPacienteUseCase(
    this._sessaoRepository,
    this._treinamentoRepository,
    this._pacienteRepository,
  );

  Future<Relatorio> call(String pacienteId) async {
    final paciente = await _pacienteRepository.getPacienteById(pacienteId);
    if (paciente == null) {
      throw Exception('Paciente não encontrado para gerar relatório.');
    }

    final treinamentosDoPaciente = await _treinamentoRepository.getTreinamentosByPacienteId(pacienteId).first;
    List<Map<String, dynamic>> detalhesTreinamentos = [];

    for (var treinamento in treinamentosDoPaciente) {
      final sessoesDoTreinamento = await _sessaoRepository.getSessoesByTreinamentoId(treinamento.id!).first;

      int sessoesRealizadas = 0;
      int sessoesFalta = 0;
      int sessoesCanceladas = 0;
      int sessoesBloqueadas = 0;
      int sessoesAgendadas = 0;

      for (var sessao in sessoesDoTreinamento) {
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

      detalhesTreinamentos.add({
        'treinamentoId': treinamento.id,
        'diaSemana': treinamento.diaSemana,
        'horario': treinamento.horario,
        'dataInicio': treinamento.dataInicio.toIso8601String(),
        'dataFimPrevista': treinamento.dataFimPrevista.toIso8601String(),
        'statusTreinamento': treinamento.status,
        'numeroSessoesTotal': treinamento.numeroSessoesTotal,
        'sessoesRealizadas': sessoesRealizadas,
        'sessoesFalta': sessoesFalta,
        'sessoesCanceladas': sessoesCanceladas,
        'sessoesBloqueadas': sessoesBloqueadas,
        'sessoesAgendadas': sessoesAgendadas,
        'detalhesSessoes': sessoesDoTreinamento.map((s) => {
          'dataHora': s.dataHora.toIso8601String(),
          'numeroSessao': s.numeroSessao,
          'status': s.status,
          'statusPagamento': s.statusPagamento,
          'observacoes': s.observacoes,
        }).toList(),
      });
    }

    final dadosRelatorio = {
      'pacienteId': paciente.id,
      'pacienteNome': paciente.nome,
      'nomeResponsavel': paciente.nomeResponsavel,
      'idade': paciente.idade,
      'statusPaciente': paciente.status,
      'totalTreinamentos': treinamentosDoPaciente.length,
      'detalhesTreinamentos': detalhesTreinamentos,
    };

    return Relatorio(
      id: 'individual_paciente_${pacienteId}_${DateTime.now().millisecondsSinceEpoch}',
      tipoRelatorio: 'Individual Paciente',
      dataGeracao: DateTime.now(),
      dados: dadosRelatorio,
    );
  }
}

