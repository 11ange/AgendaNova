// 11ange/agendanova/AgendaNova-9b6192d7a5af5a265ec3aa3d41748ca9d26ac96a/lib/domain/usecases/pagamento/registrar_pagamento_usecase.dart
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';

// Use case para registrar o pagamento de um convênio.
class RegistrarPagamentoUseCase {
  final TreinamentoRepository _treinamentoRepository;

  RegistrarPagamentoUseCase(
    this._treinamentoRepository,
  );

  Future<void> call({
    required String treinamentoId,
    required String pacienteId,
    required String formaPagamento,
    String? tipoParcelamento,
    String? guiaConvenio,
    DateTime? dataEnvioGuia,
  }) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) {
      throw Exception('Treinamento não encontrado.');
    }

    // Regra de Negócio: Este use case agora trata especificamente do pagamento por convênio,
    // que é um pagamento único registrado no treinamento.
    if (formaPagamento == 'Convenio') {
      if (guiaConvenio == null || guiaConvenio.isEmpty) {
        throw Exception('Número da guia é obrigatório para pagamento por convênio.');
      }
      if (dataEnvioGuia == null) {
        throw Exception('Data de envio da guia é obrigatória para pagamento por convênio.');
      }
      
      // Cria o objeto de pagamento
      final pagamento = Pagamento(
        treinamentoId: treinamentoId,
        pacienteId: pacienteId,
        formaPagamento: formaPagamento,
        status: 'Realizado', 
        dataPagamento: dataEnvioGuia, // A data do pagamento é a data de envio da guia
        guiaConvenio: guiaConvenio,
        dataEnvioGuia: dataEnvioGuia,
      );

      // Adiciona o pagamento à lista de pagamentos do treinamento e atualiza o documento.
      final treinamentoAtualizado = treinamento.copyWith(pagamentos: [pagamento]);
      await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);

    } else {
      // Outras formas de pagamento como "3x" e "Por sessão" são gerenciadas
      // diretamente na tela de pagamentos (PagamentosViewModel).
      throw UnsupportedError('Este use case é destinado apenas para pagamentos de convênio.');
    }
  }
}