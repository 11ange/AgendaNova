import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:agenda_treinamento/core/utils/phone_input_formatter.dart';

// Widget reutilizável para exibir um item da lista de espera em um card
class ListaEsperaCard extends StatelessWidget {
  final ListaEspera item;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final VoidCallback onExit; // NOVO CALLBACK

  const ListaEsperaCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onEdit,
    required this.onExit, // NOVO
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                      tooltip: 'Editar',
                    ),
                    // NOVO BOTÃO DE SAIR
                    IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.orange),
                      onPressed: onExit,
                      tooltip: 'Saiu da Lista',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                      tooltip: 'Remover',
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
              child: Text(
                'Cadastro: ${DateFormatter.formatDate(item.dataCadastro)}',
                style: Theme.of(context).textTheme.bodyLarge,//?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            if (item.tipoConvenio != null && item.tipoConvenio!.isNotEmpty)
              Text(
                'Atendimento: ${item.tipoConvenio}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (item.telefone != null && item.telefone!.isNotEmpty)
              Text(
                'Telefone: ${PhoneInputFormatter.formatPhoneNumber(item.telefone!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (item.observacoes != null && item.observacoes!.isNotEmpty)
              Text(
                'Observações: ${item.observacoes}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}