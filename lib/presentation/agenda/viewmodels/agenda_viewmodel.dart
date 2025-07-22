// lib/presentation/agenda/viewmodels/agenda_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agendanova/domain/usecases/agenda/definir_agenda_usecase.dart';
import 'package:agendanova/core/utils/logger.dart';

class AgendaViewModel extends ChangeNotifier {
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository = GetIt.instance<AgendaDisponibilidadeRepository>();
  final DefinirAgendaUseCase _definirAgendaUseCase = GetIt.instance<DefinirAgendaUseCase>();

  bool _isLoading = false;
  String? _errorMessage; // Variável para armazenar o erro
  Map<String, List<String>> _currentAgenda = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // Getter para o erro
  Map<String, List<String>> get currentAgenda => _currentAgenda;

  AgendaViewModel() {
    _listenToAgendaChanges();
  }

  void _listenToAgendaChanges() {
    _agendaDisponibilidadeRepository.getAgendaDisponibilidade().listen(
      (agenda) {
        _errorMessage = null; // Limpa o erro em caso de sucesso
        if (agenda != null) {
          _currentAgenda = Map.from(agenda.agenda);
        } else {
          _currentAgenda = {};
        }
        notifyListeners();
      },
      onError: (error, stackTrace) {
        // **CORREÇÃO AQUI: Lida com o erro**
        _errorMessage = 'Falha ao carregar os dados da agenda.';
        logger.e('Erro ao carregar agenda', error: error, stackTrace: stackTrace);
        notifyListeners();
      },
    );
  }

  void loadAgenda() {
    // A escuta já foi iniciada, mas podemos garantir que o estado de erro seja limpo
    _errorMessage = null;
    notifyListeners();
  }

  bool isTimeSelected(String day, String time) {
    return _currentAgenda[day]?.contains(time) ?? false;
  }

  void toggleTimeSelection(String day, String time) {
    if (_currentAgenda.containsKey(day)) {
      if (_currentAgenda[day]!.contains(time)) {
        _currentAgenda[day]!.remove(time);
      } else {
        _currentAgenda[day]!.add(time);
        _currentAgenda[day]!.sort();
      }
    } else {
      _currentAgenda[day] = [time];
    }
    notifyListeners();
  }

  Future<void> clearDayAgenda(String day) async {
    _setLoading(true);
    try {
      if (_currentAgenda.containsKey(day)) {
        _currentAgenda[day]!.clear();
      }
      await saveAgenda();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveAgenda() async {
    _setLoading(true);
    try {
      final agendaToSave = AgendaDisponibilidade(agenda: _currentAgenda);
      await _definirAgendaUseCase.call(agendaToSave);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}