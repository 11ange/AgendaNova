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
  String? _errorMessage;
  Map<String, List<String>> _currentAgenda = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, List<String>> get currentAgenda => _currentAgenda;

  AgendaViewModel() {
    _listenToAgendaChanges();
  }

  void _listenToAgendaChanges() {
    _agendaDisponibilidadeRepository.getAgendaDisponibilidade().listen(
      (agenda) {
        _errorMessage = null;
        if (agenda != null) {
          _currentAgenda = Map.from(agenda.agenda);
        } else {
          _currentAgenda = {};
        }
        
        // **CORREÇÃO AQUI:**
        // Só notifica se já houver widgets ouvindo. Isso evita a chamada
        // durante a construção inicial do widget pelo router.
        if (hasListeners) {
          notifyListeners();
        }
      },
      onError: (error, stackTrace) {
        _errorMessage = 'Falha ao carregar os dados da agenda.';
        logger.e('Erro ao carregar agenda', error: error, stackTrace: stackTrace);
        
        // **CORREÇÃO AQUI TAMBÉM:**
        if (hasListeners) {
          notifyListeners();
        }
      },
    );
  }

  void loadAgenda() {
    _errorMessage = null;
    // Não é mais necessário chamar notifyListeners() aqui,
    // pois a própria construção do widget já vai ler o estado mais recente.
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