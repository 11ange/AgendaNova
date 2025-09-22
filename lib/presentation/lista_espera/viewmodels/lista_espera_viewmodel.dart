import 'package:flutter/material.dart';
import 'package:agenda_treinamento/core/services/firebase_service.dart';
import 'package:agenda_treinamento/data/datasources/firebase_datasource.dart';
import 'package:agenda_treinamento/data/repositories/lista_espera_repository_impl.dart';
import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
import 'package:agenda_treinamento/domain/repositories/lista_espera_repository.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/adicionar_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/editar_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/remover_lista_espera_usecase.dart';
import 'dart:async';
import 'package:agenda_treinamento/core/utils/logger.dart'; // Importa o logger

// ViewModel para a tela de Lista de Espera
class ListaEsperaViewModel extends ChangeNotifier {
  final ListaEsperaRepository _listaEsperaRepository;
  final AdicionarListaEsperaUseCase _adicionarListaEsperaUseCase;
  final RemoverListaEsperaUseCase _removerListaEsperaUseCase;
  final EditarListaEsperaUseCase _editarListaEsperaUseCase;

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
      ),
      _editarListaEsperaUseCase = EditarListaEsperaUseCase(
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
        // Filtra para mostrar apenas quem está aguardando
        final aguardando = items.where((item) => item.status == 'aguardando').toList();
        aguardando.sort((a, b) => a.dataCadastro.compareTo(b.dataCadastro));
        _listaEspera = aguardando;
        _listaEsperaStreamController.add(_listaEspera);
        notifyListeners();
      },
      onError: (error, stackTrace) {
        _listaEsperaStreamController.addError(error);
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

  Future<void> editarItem(ListaEspera item) async {
    _setLoading(true);
    try {
      await _editarListaEsperaUseCase.call(item);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // NOVO MÉTODO: Marca um item como "saiu"
  Future<void> sairDaLista(ListaEspera item) async {
    _setLoading(true);
    try {
      final itemAtualizado = item.copyWith(status: 'saiu');
      await _editarListaEsperaUseCase.call(itemAtualizado);
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