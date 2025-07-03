import 'package:flutter_agenda_fono/domain/entities/pagamento.dart';
import 'package:flutter_agenda_fono/domain/entities/treinamento.dart';
import 'package:flutter_agenda_fono/domain/repositories/pagamento_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/treinamento_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/sessao_repository.dart';

// Use case para registrar um novo pagamento
class RegistrarPagamentoUseCase {
  final PagamentoRepository _pagamentoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final SessaoRepository _sessaoRepository;

  RegistrarPagamentoUseCase(
    this._pagamentoRepository,
    this._treinamentoRepository,
    this._sessaoRepository,
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

    // Regra de Negócio: Para convênios, o pagamento é registrado para o treinamento inteiro.
    if (formaPagamento == 'Convenio') {
      if (guiaConvenio == null || guiaConvenio.isEmpty) {
        throw Exception('Número da guia é obrigatório para pagamento por convênio.');
      }
      if (dataEnvioGuia == null) {
        throw Exception('Data de envio da guia é obrigatória para pagamento por convênio.');
      }
      // Criar um único registro de pagamento para o treinamento
      final pagamento = Pagamento(
        treinamentoId: treinamentoId,
        pacienteId: pacienteId,
        formaPagamento: formaPagamento,
        status: 'Realizado', // Pagamento por convênio é considerado realizado ao registrar a guia
        dataPagamento: DateTime.now(),
        guiaConvenio: guiaConvenio,
        dataEnvioGuia: dataEnvioGuia,
      );
      await _pagamentoRepository.addPagamento(pagamento);

      // Marcar todas as sessões do treinamento como pagas (se ainda não estiverem)
      final sessoes = await _sessaoRepository.getSessoesByTreinamentoId(treinamentoId).first;
      for (var sessao in sessoes) {
        if (sessao.statusPagamento == 'Pendente') {
          await _sessaoRepository.updateSessao(
            sessao.copyWith(statusPagamento: 'Realizado', dataPagamento: DateTime.now()),
          );
        }
      }
    }
    // Regra de Negócio: Para PIX ou Dinheiro é possível selecionar o parcelamento: Por sessão ou 3x.
    else if (formaPagamento == 'Pix' || formaPagamento == 'Dinheiro') {
      if (tipoParcelamento == 'Por sessão') {
        // O pagamento por sessão é gerenciado diretamente na sessão, não aqui.
        // Este use case seria para pagamentos avulsos ou parcelas de 3x.
        throw Exception('Pagamento por sessão é gerenciado na sessão individualmente.');
      } else if (tipoParcelamento == '3x') {
        // TODO: Lógica para registrar parcelas de 3x
        // Isso exigiria um mecanismo para rastrear as parcelas e seus status.
        // Por enquanto, vamos criar um registro de pagamento genérico.
        final pagamento = Pagamento(
          treinamentoId: treinamentoId,
          pacienteId: pacienteId,
          formaPagamento: formaPagamento,
          tipoParcelamento: tipoParcelamento,
          status: 'Realizado', // Considera a parcela como realizada ao ser registrada
          dataPagamento: DateTime.now(),
          observacoes: 'Parcela de 3x (implementação futura)',
        );
        await _pagamentoRepository.addPagamento(pagamento);
      } else {
        throw Exception('Tipo de parcelamento inválido para Pix/Dinheiro.');
      }
    } else {
      throw Exception('Forma de pagamento inválida.');
    }
  }
}
