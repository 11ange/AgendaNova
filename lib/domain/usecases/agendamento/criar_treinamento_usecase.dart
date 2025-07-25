import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/core/utils/date_time_helper.dart'; // Para ajudar com cálculo de datas

// Use case para criar um novo treinamento e suas sessões
class CriarTreinamentoUseCase {
  final TreinamentoRepository _treinamentoRepository;
  final SessaoRepository _sessaoRepository;
  final PacienteRepository _pacienteRepository;
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository;

  CriarTreinamentoUseCase(
    this._treinamentoRepository,
    this._sessaoRepository,
    this._pacienteRepository,
    this._agendaDisponibilidadeRepository,
  );

  Future<void> call({
    required String pacienteId,
    required String diaSemana,
    required String horario,
    required int numeroSessoesTotal,
    required DateTime dataInicio,
    required String formaPagamento,
    String? tipoParcelamento,
    String? nomeConvenio,
  }) async {
    // 1. Regra de Negócio: Um paciente só pode ter um treinamento em andamento.
    final hasActive = await _treinamentoRepository.hasActiveTreinamento(pacienteId);
    if (hasActive) {
      throw Exception('Este paciente já possui um treinamento em andamento.');
    }

    // 2. Regra de Negócio: Não é permitido sobrepor treinamentos para o mesmo dia e horário.
    final hasOverlap = await _treinamentoRepository.hasOverlap(diaSemana, horario);
    if (hasOverlap) {
      throw Exception('Já existe um treinamento agendado para este dia e horário.');
    }

    // 3. Regra de Negócio: Não é permitido agendar sessões fora dos horários cadastrados como disponíveis.
    final agendaDisponibilidade = await _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first;
    final horariosDisponiveisNoDia = agendaDisponibilidade?.agenda[diaSemana] ?? [];
    if (!horariosDisponiveisNoDia.contains(horario)) {
      throw Exception('O horário selecionado ($horario) não está disponível para $diaSemana.');
    }

    // Obter nome do paciente para a sessão
    final paciente = await _pacienteRepository.getPacienteById(pacienteId);
    if (paciente == null) {
      throw Exception('Paciente não encontrado.');
    }

    // 4. Gerar automaticamente as sessões futuras
    List<Sessao> sessoes = [];
    DateTime currentSessionDate = dataInicio;
    int sessionsCreated = 0;
    int sessionNumber = 1;

    while (sessionsCreated < numeroSessoesTotal) {
      // Ajusta a data para o dia da semana correto (se dataInicio não for o dia certo)
      currentSessionDate = DateTimeHelper.getNextWeekday(currentSessionDate, diaSemana);

      // Combina a data com o horário fixo
      final DateTime sessionDateTime = DateTime(
        currentSessionDate.year,
        currentSessionDate.month,
        currentSessionDate.day,
        int.parse(horario.split(':')[0]),
        int.parse(horario.split(':')[1]),
      );

      sessoes.add(Sessao(
        treinamentoId: '', // Será preenchido após criar o treinamento
        pacienteId: pacienteId,
        pacienteNome: paciente.nome, // Argumento obrigatório adicionado
        dataHora: sessionDateTime,
        numeroSessao: sessionNumber,
        status: 'Agendada',
        statusPagamento: 'Pendente',
        dataPagamento: null,
        observacoes: null,
        formaPagamento: formaPagamento, // Argumento obrigatório adicionado
        agendamentoStartDate: dataInicio, // Argumento obrigatório adicionado
        totalSessoes: numeroSessoesTotal, // Argumento obrigatório adicionado
        parcelamento: tipoParcelamento,
        pagamentosParcelados: null,
        reagendada: false,
      ));
      sessionsCreated++;
      sessionNumber++;
      currentSessionDate = currentSessionDate.add(const Duration(days: 7)); // Próxima semana
    }

    // Calcular dataFimPrevista (última sessão gerada)
    final dataFimPrevista = sessoes.last.dataHora;

    // Criar o treinamento
    final novoTreinamento = Treinamento(
      pacienteId: pacienteId,
      diaSemana: diaSemana,
      horario: horario,
      numeroSessoesTotal: numeroSessoesTotal,
      dataInicio: dataInicio,
      dataFimPrevista: dataFimPrevista,
      status: 'ativo',
      formaPagamento: formaPagamento,
      tipoParcelamento: tipoParcelamento,
      nomeConvenio: nomeConvenio,
      dataCadastro: DateTime.now(),
    );

    final treinamentoId = await _treinamentoRepository.addTreinamento(novoTreinamento);

    // Atualizar o treinamentoId nas sessões e adicionar as sessões
    final sessoesComTreinamentoId = sessoes.map((s) => s.copyWith(treinamentoId: treinamentoId)).toList();
    await _sessaoRepository.addMultipleSessoes(sessoesComTreinamentoId);
  }
}
