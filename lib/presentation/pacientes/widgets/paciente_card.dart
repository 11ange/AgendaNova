import 'package:flutter/material.dart';
import 'package:agendanova/domain/entities/paciente.dart'; // Caminho corrigido

// Widget reutilizável para exibir informações de um paciente em um card
class PacienteCard extends StatelessWidget {
  final Paciente paciente;
  final VoidCallback onEdit;
  final VoidCallback onInactivate;
  final VoidCallback onTap; // Adicionado para lidar com o clique no card

  const PacienteCard({
    super.key,
    required this.paciente,
    required this.onEdit,
    required this.onInactivate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell( // Permite que o card seja clicável
        onTap: onTap,
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
                      paciente.nome,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis, // Lida com nomes longos
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_off, color: Colors.red),
                        onPressed: onInactivate,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Responsável: ${paciente.nomeResponsavel}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Telefone: ${paciente.telefoneResponsavel ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Idade: ${paciente.idade} anos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
