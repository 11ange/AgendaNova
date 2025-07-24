import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Importar GetIt
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/cadastrar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/editar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';

// ViewModel para a tela de formulário de Paciente (cadastro e edição)
class PacienteFormViewModel extends ChangeNotifier {
  // Obtenha as instâncias via GetIt
  final CadastrarPacienteUseCase _cadastrarPacienteUseCase = GetIt.instance<CadastrarPacienteUseCase>();
  final EditarPacienteUseCase _editarPacienteUseCase = GetIt.instance<EditarPacienteUseCase>();
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();

  bool _isLoading = false;
  Paciente? _paciente; // Para edição

  bool get isLoading => _isLoading;
  Paciente? get paciente => _paciente;

  PacienteFormViewModel(); // Construtor sem parâmetros, pois as dependências são resolvidas via GetIt

  // Carrega os dados de um paciente existente para edição
  Future<void> loadPaciente(String pacienteId) async {
    _setLoading(true);
    try {
      final fetchedPaciente = await _pacienteRepository.getPacienteById(pacienteId);
      if (fetchedPaciente == null) {
        throw Exception('Paciente não encontrado com o ID: $pacienteId');
      }
      _paciente = fetchedPaciente; // Define o paciente carregado
    } catch (e) {
      _paciente = null; // Garante que o paciente seja nulo em caso de erro
      rethrow; // Relança a exceção para ser tratada na UI
    } finally {
      _setLoading(false); // Garante que o estado de carregamento seja resetado
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
    notifyListeners(); // Notifica os ouvintes sobre a mudança no estado de carregamento
  }
}
