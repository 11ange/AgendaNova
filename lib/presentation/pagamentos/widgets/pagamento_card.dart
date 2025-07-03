import 'package:flutter/material.dart';
import 'package:agendanova/domain/entities/pagamento.dart';
import 'package:agendanova/core/utils/date_formatter.dart';

// Widget reutilizável para exibir um registro de pagamento em um card
class PagamentoCard extends StatelessWidget {
  final Pagamento pagamento;
  final VoidCallback onRevert;

  const PagamentoCard({
    super.key,
    required this.pagamento,
    required this.onRevert,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${pagamento.formaPagamento} ${pagamento.tipoParcelamento != null ? '(${pagamento.tipoParcelamento})' : ''}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  onPressed: onRevert,
                  tooltip: 'Reverter Pagamento',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${pagamento.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Data: ${DateFormatter.formatDate(pagamento.dataPagamento)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (pagamento.guiaConvenio != null &&
                pagamento.guiaConvenio!.isNotEmpty)
              Text(
                'Guia Convênio: ${pagamento.guiaConvenio}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (pagamento.dataEnvioGuia != null)
              Text(
                'Envio Guia: ${DateFormatter.formatDate(pagamento.dataEnvioGuia!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (pagamento.observacoes != null &&
                pagamento.observacoes!.isNotEmpty)
              Text(
                'Obs: ${pagamento.observacoes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
