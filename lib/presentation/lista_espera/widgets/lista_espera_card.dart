import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
// import 'package:agenda_treinamento/core/utils/date_formatter.dart'; // Removido, pois dataCadastro será removida

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
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0), // Diminuído o margin vertical
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Diminuído o padding vertical
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Removido SizedBox entre título e subtítulos para não ter espaço
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Título em negrito
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            // const SizedBox(height: 8.0), // Removido
            if (item.telefone != null && item.telefone!.isNotEmpty)
              Text(
                'Telefone: ${item.telefone}',
                style: Theme.of(context).textTheme.bodyLarge, // Mantido bodyLarge (14.0)
              ),
            if (item.observacoes != null && item.observacoes!.isNotEmpty)
              Text(
                'Observações: ${item.observacoes}',
                style: Theme.of(context).textTheme.bodyLarge, // Mantido bodyLarge (14.0)
              ),
            // Data de Cadastro removida conforme solicitado
            // Text(
            //   'Data de Cadastro: ${DateFormatter.formatDate(item.dataCadastro)}',
            //   style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            // ),
          ],
        ),
      ),
    );
  }
}
