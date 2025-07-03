import 'package:flutter/material.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/repositories/sessao_repository_impl.dart';
import 'package:agendanova/data/repositories/treinamento_repository_impl.dart';
import 'package:agendanova/data/repositories/agenda_disponibilidade_repository_impl.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agendanova/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'dart:async';

// ViewModel para a tela de Sessões
class SessoesViewModel extends ChangeNotifier {
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository;
  final AtualizarStatusSessaoUseCase _atualizarStatusSessaoUseCase;

  List<Sessao> _sessoesDoDia = [];
  List<Sessao> get sessoesDoDia => _sessoesDoDia;

  final _sessoesDoDiaStreamController =
      StreamController<List<Sessao>>.broadcast();
  Stream<List<Sessao>> get sessoesDoDiaStream =>
      _sessoesDoDiaStreamController.stream;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SessoesViewModel({
    SessaoRepository? sessaoRepository,
    TreinamentoRepository? treinamentoRepository,
    AgendaDisponibilidadeRepository? agendaDisponibilidadeRepository,
  }) : _sessaoRepository =
           sessaoRepository ??
           SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
       _treinamentoRepository =
           treinamentoRepository ??
           TreinamentoRepositoryImpl(
             FirebaseDatasource(FirebaseService.instance),
           ),
       _agendaDisponibilidadeRepository =
           agendaDisponibilidadeRepository ??
           AgendaDisponibilidadeRepositoryImpl(
             FirebaseDatasource(FirebaseService.instance),
           ),
       _atualizarStatusSessaoUseCase = AtualizarStatusSessaoUseCase(
         sessaoRepository ??
             SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
         treinamentoRepository ??
             TreinamentoRepositoryImpl(
               FirebaseDatasource(FirebaseService.instance),
             ),
         agendaDisponibilidadeRepository ??
             AgendaDisponibilidadeRepositoryImpl(
               FirebaseDatasource(FirebaseService.instance),
             ),
       );

  // Carrega as sessões para um dia específico e escuta mudanças
  void loadSessoesForDay(DateTime date) {
    _setLoading(true);
    _sessaoRepository
        .getSessoesByDate(date)
        .listen(
          (sessoesList) {
            _sessoesDoDia = sessoesList;
            _sessoesDoDiaStreamController.add(_sessoesDoDia);
            _setLoading(false);
          },
          onError: (error) {
            _sessoesDoDiaStreamController.addError(error);
            _setLoading(false);
            print('Erro ao carregar sessões para o dia: $error');
          },
        );
  }

  // Atualiza o status de uma sessão
  Future<void> updateSessaoStatus(
    Sessao sessao,
    String novoStatus, {
    bool? desmarcarTodasFuturas,
  }) async {
    _setLoading(true);
    try {
      await _atualizarStatusSessaoUseCase.call(
        sessao: sessao,
        novoStatus: novoStatus,
        desmarcarTodasFuturas: desmarcarTodasFuturas,
      );
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Marca o pagamento de uma sessão como realizado
  Future<void> markPaymentAsRealizado(String sessaoId) async {
    _setLoading(true);
    try {
      final sessao = _sessoesDoDia.firstWhere((s) => s.id == sessaoId);
      await _sessaoRepository.updateSessao(
        sessao.copyWith(
          statusPagamento: 'Realizado',
          dataPagamento: DateTime.now(),
        ),
      );
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Desfaz o pagamento de uma sessão
  Future<void> undoPayment(String sessaoId) async {
    _setLoading(true);
    try {
      final sessao = _sessoesDoDia.firstWhere((s) => s.id == sessaoId);
      await _sessaoRepository.updateSessao(
        sessao.copyWith(statusPagamento: 'Pendente', dataPagamento: null),
      );
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
    _sessoesDoDiaStreamController.close();
    super.dispose();
  }
}
