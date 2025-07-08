import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Importar GetIt
//import 'package:agendanova/core/services/firebase_service.dart';
//import 'package:agendanova/data/datasources/firebase_datasource.dart';
//import 'package:agendanova/data/repositories/agenda_disponibilidade_repository_impl.dart';
import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agendanova/domain/usecases/agenda/definir_agenda_usecase.dart';

// ViewModel para a tela de Definição de Agenda
class AgendaViewModel extends ChangeNotifier {
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository = GetIt.instance<AgendaDisponibilidadeRepository>();
  final DefinirAgendaUseCase _definirAgendaUseCase = GetIt.instance<DefinirAgendaUseCase>();

  bool _isLoading = false;
  Map<String, List<String>> _currentAgenda = {}; // Estado local da agenda selecionada

  bool get isLoading => _isLoading;
  Map<String, List<String>> get currentAgenda => _currentAgenda;

  AgendaViewModel() {
    _listenToAgendaChanges();
  }

  // Escuta as mudanças na agenda do Firestore em tempo real
  void _listenToAgendaChanges() {
    _agendaDisponibilidadeRepository.getAgendaDisponibilidade().listen(
      (agenda) {
        if (agenda != null) {
          _currentAgenda = Map.from(agenda.agenda); // Cria uma cópia para poder modificar
        } else {
          _currentAgenda = {}; // Agenda vazia se não houver dados no Firestore
        }
        notifyListeners();
      },
      onError: (error) {
        // TODO: Lidar com o erro, talvez mostrar uma mensagem para o usuário
        // print('Erro ao carregar agenda: $error'); // Evitar print em produção
      },
    );
  }

  // Carrega a agenda inicial (chamado na inicialização da tela)
  void loadAgenda() {
    // A escuta já é iniciada no construtor, então a agenda será carregada automaticamente.
    // Este método pode ser usado para forçar um recarregamento se necessário.
  }

  // Verifica se um horário está selecionado para um determinado dia
  bool isTimeSelected(String day, String time) {
    return _currentAgenda[day]?.contains(time) ?? false;
  }

  // Alterna a seleção de um horário
  void toggleTimeSelection(String day, String time) {
    if (_currentAgenda.containsKey(day)) {
      if (_currentAgenda[day]!.contains(time)) {
        _currentAgenda[day]!.remove(time);
      } else {
        _currentAgenda[day]!.add(time);
        _currentAgenda[day]!.sort(); // Mantém os horários ordenados
      }
    } else {
      _currentAgenda[day] = [time];
    }
    notifyListeners();
  }

  // NOVO MÉTODO: Limpa todos os horários para um dia específico e salva
  Future<void> clearDayAgenda(String day) async {
    _setLoading(true);
    try {
      if (_currentAgenda.containsKey(day)) {
        _currentAgenda[day]!.clear(); // Limpa a lista de horários para o dia
      }
      await saveAgenda(); // Salva a agenda atualizada no Firestore
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Salva a agenda atual no Firestore
  Future<void> saveAgenda() async {
    _setLoading(true);
    try {
      final agendaToSave = AgendaDisponibilidade(agenda: _currentAgenda);
      await _definirAgendaUseCase.call(agendaToSave);
    } catch (e) {
      rethrow; // Relança a exceção para ser tratada na UI
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
