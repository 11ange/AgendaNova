import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/widgets/paciente_card.dart';
import 'package:agenda_treinamento/core/utils/snackbar_helper.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<PacientesViewModel>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PacientesViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestão de Pacientes',
        onBackButtonPressed: () => context.go('/home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => context.push('/paciente-form'),
            tooltip: 'Cadastrar Novo Paciente',
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => viewModel.setFilter(PacienteFilter.arquivados),
            tooltip: 'Ver Arquivados',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar paciente',
                hintText: 'Nome ou responsável',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Filtros Rápidos (UX)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(context, 'Ativos', PacienteFilter.ativos, viewModel),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Inativos', PacienteFilter.inativos, viewModel),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Arquivados', PacienteFilter.arquivados, viewModel),
              ],
            ),
          ),

          // Lista de Pacientes
          Expanded(
            child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.filteredPacientes.isEmpty
                ? _buildEmptyState(context, viewModel)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: viewModel.filteredPacientes.length,
                    itemBuilder: (context, index) {
                      final paciente = viewModel.filteredPacientes[index];
                      return PacienteCard(
                        paciente: paciente,
                        onTap: () => context.push('/paciente-historico/${paciente.id}'),
                        onEdit: () => context.push('/paciente-form?id=${paciente.id}'),
                        actionIcon: _getActionIcon(paciente.status),
                        actionTooltip: _getActionTooltip(paciente.status),
                        onAction: () => _handleAction(context, viewModel, paciente),
                        secondaryActionIcon: paciente.status == 'inativo' ? Icons.archive : null,
                        secondaryActionTooltip: 'Arquivar Paciente',
                        onSecondaryAction: paciente.status == 'inativo' 
                          ? () => _handleSecondaryAction(context, viewModel, paciente)
                          : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, PacienteFilter filter, PacientesViewModel viewModel, {String? tooltip}) {
    final isSelected = viewModel.currentFilter == filter;
    return Tooltip(
      message: tooltip ?? label,
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) viewModel.setFilter(filter);
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  IconData _getActionIcon(String status) {
    if (status == 'ativo') return Icons.person_off;
    return Icons.person_add_alt_1;
  }

  String _getActionTooltip(String status) {
    if (status == 'ativo') return 'Inativar Paciente';
    return 'Reativar Paciente';
  }

  Future<void> _handleAction(BuildContext context, PacientesViewModel viewModel, Paciente paciente) async {
    final isAtivo = paciente.status == 'ativo';
    final title = isAtivo ? 'Inativar' : 'Reativar';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title Paciente'),
        content: Text('Deseja $title ${paciente.nome}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(title)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (isAtivo) {
          await viewModel.inativarPaciente(paciente.id!);
          if (mounted) SnackBarHelper.showSuccess(context, 'Paciente inativado com sucesso!');
        } else {
          await viewModel.reativarPaciente(paciente.id!);
          if (mounted) SnackBarHelper.showSuccess(context, 'Paciente reativado com sucesso!');
        }
      } catch (e) {
        if (mounted) SnackBarHelper.showError(context, e);
      }
    }
  }

  Future<void> _handleSecondaryAction(BuildContext context, PacientesViewModel viewModel, Paciente paciente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar Paciente'),
        content: const Text('Deseja arquivar definitivamente este paciente? Ele sairá da lista de inativos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Arquivar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await viewModel.arquivarPaciente(paciente.id!);
        if (mounted) SnackBarHelper.showSuccess(context, 'Paciente arquivado com sucesso!');
      } catch (e) {
        if (mounted) SnackBarHelper.showError(context, e);
      }
    }
  }

  Widget _buildEmptyState(BuildContext context, PacientesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhum paciente encontrado.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          if (viewModel.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Critério: "${viewModel.searchQuery}"', style: const TextStyle(color: Colors.grey)),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/paciente-form'),
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar Novo Paciente'),
          ),
        ],
      ),
    );
  }
}
