import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/pagamento/registrar_pagamento_usecase.dart';

import 'registrar_pagamento_usecase_test.mocks.dart';

@GenerateMocks([TreinamentoRepository])
void main() {
  late MockTreinamentoRepository mockRepository;
  late RegistrarPagamentoUseCase usecase;

  setUp(() {
    mockRepository = MockTreinamentoRepository();
    usecase = RegistrarPagamentoUseCase(mockRepository);
  });

  final tTreinamento = Treinamento(
    id: 't1',
    pacienteId: 'p1',
    diaSemana: 'Segunda-feira',
    horario: '14:00',
    dataInicio: DateTime(2025, 1, 1),
    dataFimPrevista: DateTime(2025, 3, 1),
    numeroSessoesTotal: 10,
    status: 'ativo',
    formaPagamento: 'Convenio',
    dataCadastro: DateTime.now(),
  );

  group('RegistrarPagamentoUseCase', () {
    test('deve atualizar o treinamento com o novo pagamento de convênio', () async {
      when(mockRepository.getTreinamentoById('t1')).thenAnswer((_) async => tTreinamento);
      when(mockRepository.updateTreinamento(any)).thenAnswer((_) async => {});

      final dataEnvio = DateTime(2025, 1, 20);

      await usecase.call(
        treinamentoId: 't1',
        pacienteId: 'p1',
        formaPagamento: 'Convenio',
        guiaConvenio: 'GUIA-123',
        dataEnvioGuia: dataEnvio,
      );

      verify(mockRepository.getTreinamentoById('t1')).called(1);
      verify(mockRepository.updateTreinamento(argThat(predicate((t) {
        if (t is! Treinamento) return false;
        if (t.pagamentos == null || t.pagamentos!.isEmpty) return false;
        final p = t.pagamentos!.first;
        return p.formaPagamento == 'Convenio' && 
               p.guiaConvenio == 'GUIA-123' && 
               p.dataPagamento == dataEnvio;
      })))).called(1);
    });

    test('deve lançar exceção se treinamento não for encontrado', () async {
      when(mockRepository.getTreinamentoById(any)).thenAnswer((_) async => null);

      expect(
        () => usecase.call(
          treinamentoId: 't-invalido',
          pacienteId: 'p1',
          formaPagamento: 'Convenio',
          guiaConvenio: 'GUIA-123',
          dataEnvioGuia: DateTime.now(),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
