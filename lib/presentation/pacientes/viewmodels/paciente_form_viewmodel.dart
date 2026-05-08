import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/cadastrar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/editar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';

// ViewModel para a tela de formulário de Paciente (cadastro e edição)
class PacienteFormViewModel extends ChangeNotifier {
  final CadastrarPacienteUseCase _cadastrarPacienteUseCase;
  final EditarPacienteUseCase _editarPacienteUseCase;
  final ReativarPacienteUseCase _reativarPacienteUseCase;
  final PacienteRepository _pacienteRepository;

  bool _isLoading = false;
  Paciente? _paciente;

  bool get isLoading => _isLoading;
  Paciente? get paciente => _paciente;

  PacienteFormViewModel(
    this._cadastrarPacienteUseCase,
    this._editarPacienteUseCase,
    this._reativarPacienteUseCase,
    this._pacienteRepository,
  );

  Future<void> loadPaciente(String pacienteId) async {
    _setLoading(true);
    try {
      final fetchedPaciente = await _pacienteRepository.getPacienteById(pacienteId);
      if (fetchedPaciente == null) {
        throw Exception('Paciente não encontrado com o ID: $pacienteId');
      }
      _paciente = fetchedPaciente;
    } catch (e) {
      _paciente = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cadastrarPaciente(Paciente paciente, {bool ignoreHomonym = false}) async {
    _setLoading(true);
    try {
      await _cadastrarPacienteUseCase.call(paciente, ignoreHomonym: ignoreHomonym);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editarPaciente(Paciente paciente) async {
    _setLoading(true);
    try {
      await _editarPacienteUseCase.call(paciente);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reativarPaciente(String id) async {
    _setLoading(true);
    try {
      await _reativarPacienteUseCase.call(id);
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
