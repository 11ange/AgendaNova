import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/inativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/arquivar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'dart:async';

enum PacienteFilter { ativos, inativos, arquivados }

class PacientesViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository;
  final InativarPacienteUseCase _inativarPacienteUseCase;
  final ReativarPacienteUseCase _reativarPacienteUseCase;
  final ArquivarPacienteUseCase _arquivarPacienteUseCase;

  List<Paciente> _allPacientes = [];
  List<Paciente> _filteredPacientes = [];
  String _searchQuery = '';
  PacienteFilter _currentFilter = PacienteFilter.ativos;
  bool _isLoading = true;

  List<Paciente> get filteredPacientes => _filteredPacientes;
  PacienteFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  StreamSubscription? _pacientesSubscription;

  PacientesViewModel(
    this._pacienteRepository,
    this._inativarPacienteUseCase,
    this._reativarPacienteUseCase,
    this._arquivarPacienteUseCase,
  ) {
    _listenToPacientes();
  }

  void _listenToPacientes() {
    _isLoading = true;
    notifyListeners();

    _pacientesSubscription?.cancel();
    // Usamos getPacientes() que retorna Ativos e Inativos
    // Para Arquivados, precisaremos decidir se incluímos no mesmo stream ou fazemos merge
    _pacientesSubscription = _pacienteRepository.getPacientes().listen(
      (pacientesList) {
        _allPacientes = pacientesList;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setFilter(PacienteFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPacientes = _allPacientes.where((p) {
      // 1. Filtro por Status/Tipo
      bool matchesFilter = false;
      switch (_currentFilter) {
        case PacienteFilter.ativos:
          matchesFilter = p.status == 'ativo';
          break;
        case PacienteFilter.inativos:
          matchesFilter = p.status == 'inativo';
          break;
        case PacienteFilter.arquivados:
          matchesFilter = p.status == 'arquivado';
          break;
      }

      if (!matchesFilter) return false;

      // 2. Filtro por Busca
      if (_searchQuery.isEmpty) return true;
      
      final query = _searchQuery.toLowerCase();
      return p.nome.toLowerCase().contains(query) || 
             p.nomeResponsavel.toLowerCase().contains(query);
    }).toList();

    // Ordenação alfabética
    _filteredPacientes.sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<void> inativarPaciente(String id) async {
    await _inativarPacienteUseCase.call(id);
  }

  Future<void> reativarPaciente(String id) async {
    await _reativarPacienteUseCase.call(id);
  }

  Future<void> arquivarPaciente(String id) async {
    await _arquivarPacienteUseCase.call(id);
  }

  @override
  void dispose() {
    _pacientesSubscription?.cancel();
    super.dispose();
  }
}
