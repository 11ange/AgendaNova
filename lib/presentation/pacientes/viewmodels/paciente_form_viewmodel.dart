import 'package:flutter/material.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/repositories/paciente_repository_impl.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/usecases/paciente/cadastrar_paciente_usecase.dart';
import 'package:agendanova/domain/usecases/paciente/editar_paciente_usecase.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';

// ViewModel para a tela de formulário de Paciente (cadastro e edição)
class PacienteFormViewModel extends ChangeNotifier {
  final CadastrarPacienteUseCase _cadastrarPacienteUseCase;
  final EditarPacienteUseCase _editarPacienteUseCase;
  final PacienteRepository _pacienteRepository; // Para carregar o paciente existente

  bool _isLoading = false;
  Paciente? _paciente; // Para edição

  bool get isLoading => _isLoading;
  Paciente? get paciente => _paciente;

  PacienteFormViewModel({PacienteRepository? pacienteRepository})
      : _pacienteRepository = pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _cadastrarPacienteUseCase = CadastrarPacienteUseCase(pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance))),
        _editarPacienteUseCase = EditarPacienteUseCase(pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)));

  // Carrega os dados de um paciente existente para edição
  Future<void> loadPaciente(String pacienteId) async {
    _setLoading(true);
    try {
      _paciente = await _pacienteRepository.getPacienteById(pacienteId);
      if (_paciente == null) {
        throw Exception('Paciente não encontrado.');
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cadastra um novo paciente
  Future<void> cadastrarPaciente(Paciente paciente) async {
    _setLoading(true);
    try {
      await _cadastrarPacienteUseCase.call(paciente);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Edita um paciente existente
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

