import 'package:flutter/material.dart';
import 'package:flutter_agenda_fono/domain/entities/lista_espera.dart';
import 'package:flutter_agenda_fono/core/utils/date_formatter.dart';

// Widget reutilizável para exibir um item da lista de espera em um card
class ListaEsperaCard extends StatelessWidget {
  final ListaEspera item;
  final VoidCallback onRemove;

  const ListaEsperaCard({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.nome,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (item.telefone != null && item.telefone!.isNotEmpty)
              Text(
                'Telefone: ${item.telefone}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (item.observacoes != null && item.observacoes!.isNotEmpty)
              Text(
                'Observações: ${item.observacoes}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            Text(
              'Data de Cadastro: ${DateFormatter.formatDate(item.dataCadastro)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

