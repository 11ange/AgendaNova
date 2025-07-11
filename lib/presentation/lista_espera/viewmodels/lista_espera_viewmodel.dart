import 'package:flutter/material.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/repositories/lista_espera_repository_impl.dart';
import 'package:agendanova/domain/entities/lista_espera.dart';
import 'package:agendanova/domain/repositories/lista_espera_repository.dart';
import 'package:agendanova/domain/usecases/lista_espera/adicionar_lista_espera_usecase.dart';
import 'package:agendanova/domain/usecases/lista_espera/remover_lista_espera_usecase.dart';
import 'dart:async';
import 'package:agendanova/core/utils/logger.dart'; // Importa o logger

// ViewModel para a tela de Lista de Espera
class ListaEsperaViewModel extends ChangeNotifier {
  final ListaEsperaRepository _listaEsperaRepository;
  final AdicionarListaEsperaUseCase _adicionarListaEsperaUseCase;
  final RemoverListaEsperaUseCase _removerListaEsperaUseCase;

  List<ListaEspera> _listaEspera = [];
  List<ListaEspera> get listaEspera => _listaEspera;

  final _listaEsperaStreamController =
      StreamController<List<ListaEspera>>.broadcast();
  Stream<List<ListaEspera>> get listaEsperaStream =>
      _listaEsperaStreamController.stream;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ListaEsperaViewModel({ListaEsperaRepository? listaEsperaRepository})
    : _listaEsperaRepository =
          listaEsperaRepository ??
          ListaEsperaRepositoryImpl(
            FirebaseDatasource(FirebaseService.instance),
          ),
      _adicionarListaEsperaUseCase = AdicionarListaEsperaUseCase(
        listaEsperaRepository ??
            ListaEsperaRepositoryImpl(
              FirebaseDatasource(FirebaseService.instance),
            ),
      ),
      _removerListaEsperaUseCase = RemoverListaEsperaUseCase(
        listaEsperaRepository ??
            ListaEsperaRepositoryImpl(
              FirebaseDatasource(FirebaseService.instance),
            ),
      ) {
    _listenToListaEspera();
  }

  void _listenToListaEspera() {
    _listaEsperaRepository.getListaEspera().listen(
      (items) {
        // Ordena a lista pelo mais antigo primeiro (dataCadastro ascendente)
        items.sort((a, b) => a.dataCadastro.compareTo(b.dataCadastro));
        _listaEspera = items;
        _listaEsperaStreamController.add(_listaEspera);
        notifyListeners();
      },
      onError: (error, stackTrace) { // Captura o erro e o stack trace
        _listaEsperaStreamController.addError(error);
        // CORREÇÃO: Usa o logger para registrar o erro
        logger.e('Erro ao carregar lista de espera', error: error, stackTrace: stackTrace);
      },
    );
  }

  Future<void> adicionarItem(ListaEspera item) async {
    _setLoading(true);
    try {
      await _adicionarListaEsperaUseCase.call(item);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removerItem(String id) async {
    _setLoading(true);
    try {
      await _removerListaEsperaUseCase.call(id);
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

  @override
  void dispose() {
    _listaEsperaStreamController.close();
    super.dispose();
  }
}
