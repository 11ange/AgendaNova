// test/domain/usecases/pagamento/reverter_pagamento_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/repositories/pagamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/pagamento/reverter_pagamento_usecase.dart';
import 'dart:async';

@GenerateMocks([PagamentoRepository, SessaoRepository, TreinamentoRepository])
import 'reverter_pagamento_usecase_test.mocks.dart';

void main() {
  late ReverterPagamentoUseCase usecase;
  late MockPagamentoRepository mockPagamentoRepository;
  late MockSessaoRepository mockSessaoRepository;
  late MockTreinamentoRepository mockTreinamentoRepository;

  setUp(() {
    mockPagamentoRepository = MockPagamentoRepository();
    mockSessaoRepository = MockSessaoRepository();
    mockTreinamentoRepository = MockTreinamentoRepository();
    usecase = ReverterPagamentoUseCase(
      mockPagamentoRepository,
      mockSessaoRepository,
      mockTreinamentoRepository,
    );
  });

  group('ReverterPagamentoUseCase', () {
    const pagamentoId = 'pagamento-id-1';
    const treinamentoId = 'treinamento-id-1';

    final pagamentoRealizado = Pagamento(
      id: pagamentoId,
      treinamentoId: treinamentoId,
      pacienteId: 'paciente-id-1',
      formaPagamento: 'Pix',
      status: 'Realizado',
      dataPagamento: DateTime.now(),
    );

    final treinamentoFinalizado = Treinamento(
      id: treinamentoId,
      pacienteId: 'paciente-id-1',
      diaSemana: 'Segunda-feira',
      horario: '14:30',
      numeroSessoesTotal: 10,
      dataInicio: DateTime(2025, 1, 1),
      dataFimPrevista: DateTime(2025, 3, 10),
      status: 'Finalizado',
      formaPagamento: 'Pix',
      dataCadastro: DateTime.now(),
    );

    test('deve reverter o status do pagamento para Pendente e atualizar o status do treinamento para Pendente Pagamento', () async {
      // ARRANGE
      when(mockPagamentoRepository.getPagamentos()).thenAnswer((_) => Stream.value([pagamentoRealizado]));
      when(mockPagamentoRepository.updatePagamento(any)).thenAnswer((_) async => Future.value());
      when(mockTreinamentoRepository.getTreinamentoById(treinamentoId)).thenAnswer((_) async => treinamentoFinalizado);
      when(mockTreinamentoRepository.updateTreinamento(any)).thenAnswer((_) async => Future.value());
      
      // ACT
      await usecase.call(pagamentoId);

      // ASSERT
      // captura o objeto passado para updateTreinamento
      final updatedTreinamento = verify(mockTreinamentoRepository.updateTreinamento(captureAny))
          .captured
          .single as Treinamento;

      // valida apenas o que importa
      expect(updatedTreinamento.status, 'Pendente Pagamento');
      expect(updatedTreinamento.id, treinamentoId);
    });


    test('não deve alterar o status do treinamento se ele não estava Finalizado', () async {
      // ARRANGE
      final treinamentoAtivo = treinamentoFinalizado.copyWith(status: 'ativo');
      when(mockPagamentoRepository.getPagamentos()).thenAnswer((_) => Stream.value([pagamentoRealizado]));
      when(mockPagamentoRepository.updatePagamento(any)).thenAnswer((_) async => Future.value());
      when(mockTreinamentoRepository.getTreinamentoById(treinamentoId)).thenAnswer((_) async => treinamentoAtivo);
      when(mockTreinamentoRepository.updateTreinamento(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pagamentoId);

      // ASSERT
      verify(mockPagamentoRepository.updatePagamento(any)).called(1);
      verifyNever(mockTreinamentoRepository.updateTreinamento(any));
    });
    
    test('deve lançar uma exceção se o pagamento não for encontrado', () async {
       // ARRANGE
      when(mockPagamentoRepository.getPagamentos()).thenAnswer((_) => Stream.value([]));
      
      // ACT & ASSERT
      await expectLater(() => usecase.call('id-inexistente'), throwsA(isA<Exception>()));
      verify(mockPagamentoRepository.getPagamentos()).called(1);
      verifyNever(mockPagamentoRepository.updatePagamento(any));
    });

    test('deve reverter o pagamento de convênio e todas as sessões relacionadas', () async {
      // ARRANGE
      final pagamentoConvenio = pagamentoRealizado.copyWith(formaPagamento: 'Convenio');
      final sessoesConvenio = [
        Sessao(id: 's1', treinamentoId: treinamentoId, pacienteId: 'p1', pacienteNome: 'P1', dataHora: DateTime.now(), numeroSessao: 1, status: 'Realizada', statusPagamento: 'Realizado', formaPagamento: 'Convenio', agendamentoStartDate: DateTime.now(), totalSessoes: 2),
        Sessao(id: 's2', treinamentoId: treinamentoId, pacienteId: 'p1', pacienteNome: 'P1', dataHora: DateTime.now().add(Duration(days: 7)), numeroSessao: 2, status: 'Agendada', statusPagamento: 'Realizado', formaPagamento: 'Convenio', agendamentoStartDate: DateTime.now(), totalSessoes: 2),
      ];
      final treinamentoConvenio = treinamentoFinalizado.copyWith(formaPagamento: 'Convenio');

      when(mockPagamentoRepository.getPagamentos()).thenAnswer((_) => Stream.value([pagamentoConvenio]));
      when(mockPagamentoRepository.updatePagamento(any)).thenAnswer((_) async => Future.value());
      when(mockSessaoRepository.getSessoesByTreinamentoId(treinamentoId)).thenAnswer((_) => Stream.value(sessoesConvenio));
      when(mockSessaoRepository.updateSessao(any)).thenAnswer((_) async => Future.value());
      when(mockTreinamentoRepository.getTreinamentoById(treinamentoId)).thenAnswer((_) async => treinamentoConvenio);
      when(mockTreinamentoRepository.updateTreinamento(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pagamentoId);

      // ASSERT - captura os parâmetros atualizados em vez de comparar objetos inteiros
      final updatedPagamento = verify(mockPagamentoRepository.updatePagamento(captureAny)).captured.single as Pagamento;
      expect(updatedPagamento.status, 'Pendente');
      //expect(updatedPagamento.dataPagamento, null);

      final capturedSessoes = verify(mockSessaoRepository.updateSessao(captureAny)).captured;
      expect(capturedSessoes.length, 2);
      expect((capturedSessoes[0] as Sessao).statusPagamento, 'Pendente');
      expect((capturedSessoes[0] as Sessao).dataPagamento, null);
      expect((capturedSessoes[1] as Sessao).statusPagamento, 'Pendente');
      expect((capturedSessoes[1] as Sessao).dataPagamento, null);
    });
  });
}
