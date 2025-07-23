import 'package:flutter/material.dart';
import 'package:agendanova/domain/entities/paciente.dart';

// Widget reutilizável para exibir informações de um paciente em um card
class PacienteCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onEdit;
  final VoidCallback onAction;
  final VoidCallback onTap;
  final IconData? actionIcon;
  final String? actionTooltip;

  const PacienteCard({
    super.key,
    required this.paciente,
    required this.onEdit,
    required this.onAction,
    required this.onTap,
    this.actionIcon,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      paciente.nome,
                      style: Theme.of(context).textTheme.titleMedium,
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
                        icon: Icon(actionIcon ?? Icons.person_off, color: Colors.red),
                        onPressed: onAction,
                        tooltip: actionTooltip ?? 'Inativar Paciente',
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'Responsável: ${paciente.nomeResponsavel}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Idade: ${paciente.idade} anos',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}