import 'package:flutter/material.dart';
import 'package:agendanova/domain/entities/paciente.dart'; // Importação corrigida

// Widget reutilizável para exibir informações de um paciente em um card
class PacienteCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onEdit;
  final VoidCallback onAction; // Renomeado de onInactivate para onAction para ser mais genérico
  final VoidCallback onTap;
  final IconData? actionIcon; // Novo parâmetro para o ícone da ação
  final String? actionTooltip; // Novo parâmetro para o tooltip da ação

  const PacienteCard({
    super.key,
    required this.paciente,
    required this.onEdit,
    required this.onAction, // Usando o novo nome
    required this.onTap,
    this.actionIcon, // Ícone opcional
    this.actionTooltip, // Tooltip opcional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0), // Reduzido ainda mais o margin vertical
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0), // Reduzido ainda mais o padding vertical
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      paciente.nome,
                      style: Theme.of(context).textTheme.titleMedium, // Usará o novo tamanho do tema (16.0)
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                        tooltip: 'Editar Paciente',
                      ),
                      IconButton(
                        // Usa o ícone e tooltip fornecidos, ou um padrão
                        icon: Icon(actionIcon ?? Icons.person_off, color: Colors.red),
                        onPressed: onAction,
                        tooltip: actionTooltip ?? 'Inativar Paciente',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2.0), // Reduzido o espaçamento
              Text(
                'Responsável: ${paciente.nomeResponsavel}',
                style: Theme.of(context).textTheme.bodyMedium, // Usará o novo tamanho do tema (12.0)
              ),
              // Telefone removido conforme solicitado
              // Text(
              //   'Telefone: ${paciente.telefoneResponsavel ?? 'N/A'}',
              //   style: Theme.of(context).textTheme.bodyMedium, // Usará o novo tamanho do tema (12.0)
              // ),
              Text(
                'Idade: ${paciente.idade} anos',
                style: Theme.of(context).textTheme.bodyMedium, // Usará o novo tamanho do tema (12.0)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
