// lib/presentation/lista_espera/pages/lista_espera_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/domain/entities/lista_espera.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart';
import 'package:agenda_treinamento/presentation/lista_espera/widgets/lista_espera_card.dart';
import 'package:agenda_treinamento/core/utils/input_validators.dart';
import 'package:agenda_treinamento/core/utils/phone_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/core/utils/snackbar_helper.dart';

class ListaEsperaPage extends StatefulWidget {
  const ListaEsperaPage({super.key});

  @override
  State<ListaEsperaPage> createState() => _ListaEsperaPageState();
}

class _ListaEsperaPageState extends State<ListaEsperaPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedConvenio;
  String? _activeTipoConvenioFilter;

  @override
  void initState() {
    super.initState();
    // Adiciona o listener para o campo de busca para reconstruir a UI ao digitar
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddOrEditDialog(BuildContext context, ListaEsperaViewModel viewModel, {ListaEspera? item}) async {
    final isEditing = item != null;

    _nomeController.text = item?.nome ?? '';
    _telefoneController.text = item?.telefone != null ? PhoneInputFormatter.formatPhoneNumber(item!.telefone!) : '';
    _observacoesController.text = item?.observacoes ?? '';
    _selectedConvenio = item?.tipoConvenio;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Item' : 'Adicionar à Lista de Espera'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(labelText: 'Nome *'),
                        validator: (value) => InputValidators.requiredField(value, 'Nome'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          counterText: '',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => InputValidators.phone(value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneInputFormatter(),
                        ],
                        maxLength: 15,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedConvenio,
                        decoration: const InputDecoration(labelText: 'Tipo de Atendimento'),
                        style: Theme.of(context).textTheme.bodyLarge,
                        items: ['Particular', 'Convênio', 'SOBAM']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedConvenio = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _observacoesController,
                        decoration: const InputDecoration(labelText: 'Observações'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final telefoneApenasDigitos = _telefoneController.text.replaceAll(RegExp(r'\D'), '');
                      final navigator = Navigator.of(dialogContext);

                      try {
                        if (isEditing) {
                          final updatedItem = item.copyWith(
                            nome: _nomeController.text,
                            telefone: telefoneApenasDigitos.isEmpty ? null : telefoneApenasDigitos,
                            observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
                            tipoConvenio: _selectedConvenio,
                          );
                          await viewModel.editarItem(updatedItem);
                          if (!context.mounted) return;
                          SnackBarHelper.showSuccess(context, 'Item atualizado com sucesso!');
                        } else {
                          final newItem = ListaEspera(
                            nome: _nomeController.text,
                            telefone: telefoneApenasDigitos.isEmpty ? null : telefoneApenasDigitos,
                            observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
                            dataCadastro: DateTime.now(),
                            tipoConvenio: _selectedConvenio,
                          );
                          await viewModel.adicionarItem(newItem);
                          if (!context.mounted) return;
                          SnackBarHelper.showSuccess(context, 'Adicionado à lista de espera com sucesso!');
                        }
                        navigator.pop();
                      } catch (e) {
                        if (!context.mounted) return;
                        SnackBarHelper.showError(context, e);
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalWidget(String label, int count, String filterType) {
    final isSelected = _activeTipoConvenioFilter == filterType;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _activeTipoConvenioFilter = null;
          } else {
            _activeTipoConvenioFilter = filterType;
          }
        });
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          '$label: $count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Lista de Espera',
        onBackButtonPressed: () => context.go('/home'),
      ),
      body: Consumer<ListaEsperaViewModel>(
        builder: (context, viewModel, child) {
          final particularCount = viewModel.listaEspera.where((item) => item.tipoConvenio == 'Particular').length;
          final convenioCount = viewModel.listaEspera.where((item) => item.tipoConvenio == 'Convênio').length;
          final sobamCount = viewModel.listaEspera.where((item) => item.tipoConvenio == 'SOBAM').length;

          // --- LÓGICA DE FILTRO MOVIDA DIRETAMENTE PARA O BUILD ---
          List<ListaEspera> displayedList = viewModel.listaEspera;
          final searchQuery = _searchController.text.toLowerCase();

          if (searchQuery.isNotEmpty) {
            displayedList = displayedList
                .where((item) => item.nome.toLowerCase().contains(searchQuery))
                .toList();
          }

          if (_activeTipoConvenioFilter != null) {
            displayedList = displayedList
                .where((item) => item.tipoConvenio == _activeTipoConvenioFilter)
                .toList();
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nome',
                    hintText: 'Digite o nome para buscar',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTotalWidget('Particular', particularCount, 'Particular'),
                    _buildTotalWidget('Convênio', convenioCount, 'Convênio'),
                    _buildTotalWidget('SOBAM', sobamCount, 'SOBAM'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddOrEditDialog(context, viewModel),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Adicionar Pessoa'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (viewModel.isLoading && viewModel.listaEspera.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (displayedList.isEmpty && (searchQuery.isNotEmpty || _activeTipoConvenioFilter != null)) {
                      return const Center(child: Text('Nenhum resultado encontrado para os filtros aplicados.'));
                    } 
                    
                    if (viewModel.listaEspera.isEmpty) {
                      return const Center(child: Text('A lista de espera está vazia.'));
                    }

                    return ListView.builder(
                      itemCount: displayedList.length,
                      itemBuilder: (context, index) {
                        final item = displayedList[index];
                        return ListaEsperaCard(
                          item: item,
                          onEdit: () => _showAddOrEditDialog(context, viewModel, item: item),
                          onExit: () async {
                            final confirm = await _showConfirmationDialog(context,
                                'Confirmar Saída', 'Tem certeza que ${item.nome} saiu da lista de espera?');
                            
                            if (confirm == true) {
                              try {
                                await viewModel.sairDaLista(item);
                                if (!context.mounted) return;
                                SnackBarHelper.showSuccess(context, '${item.nome} foi removido(a) da lista de espera.');
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackBarHelper.showError(context, e);
                              }
                            }
                          },
                          onRemove: () async {
                            final confirm = await _showConfirmationDialog(context,
                                'Confirmar Remoção', 'Tem certeza que deseja remover ${item.nome} da lista de espera? Esta ação não pode ser desfeita.');
                            
                            if (confirm == true) {
                              try {
                                await viewModel.removerItem(item.id!);
                                if (!context.mounted) return;
                                SnackBarHelper.showSuccess(context, 'Removido da lista de espera com sucesso!');
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackBarHelper.showError(context, e);
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}