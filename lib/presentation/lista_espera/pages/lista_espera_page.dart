import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/lista_espera.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart'; // Será criado em breve
import 'package:agendanova/presentation/lista_espera/widgets/lista_espera_card.dart'; // Será criado em breve
import 'package:agendanova/core/utils/input_validators.dart';
import 'package:provider/provider.dart';

// Tela de Lista de Espera
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

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _showAddToListaEsperaDialog(
    BuildContext context,
    ListaEsperaViewModel viewModel,
  ) async {
    _nomeController.clear();
    _telefoneController.clear();
    _observacoesController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar no botão
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar à Lista de Espera'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome *'),
                    validator: (value) =>
                        InputValidators.requiredField(value, 'Nome'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _telefoneController,
                    decoration: const InputDecoration(labelText: 'Telefone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => InputValidators.phone(value),
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
              child: const Text('Adicionar'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newItem = ListaEspera(
                    nome: _nomeController.text,
                    telefone: _telefoneController.text.isEmpty
                        ? null
                        : _telefoneController.text,
                    observacoes: _observacoesController.text.isEmpty
                        ? null
                        : _observacoesController.text,
                    dataCadastro: DateTime.now(),
                  );
                  try {
                    await viewModel.adicionarItem(newItem);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Adicionado à lista de espera com sucesso!',
                          ),
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao adicionar: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListaEsperaViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Lista de Espera',
          onBackButtonPressed: () => context.go('/home'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddToListaEsperaDialog(
                    context,
                    Provider.of<ListaEsperaViewModel>(context, listen: false),
                  ),
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
              child: Consumer<ListaEsperaViewModel>(
                builder: (context, viewModel, child) {
                  return StreamBuilder<List<ListaEspera>>(
                    stream: viewModel.listaEsperaStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar lista de espera: ${snapshot.error}',
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('A lista de espera está vazia.'),
                        );
                      }

                      // A ordenação já é feita no ViewModel, então apenas exibe
                      final sortedList = snapshot.data!;

                      return ListView.builder(
                        itemCount: sortedList.length,
                        itemBuilder: (context, index) {
                          final item = sortedList[index];
                          return ListaEsperaCard(
                            item: item,
                            onRemove: () async {
                              final confirm = await _showConfirmationDialog(
                                context,
                                'Confirmar Remoção',
                                'Tem certeza que deseja remover ${item.nome} da lista de espera?',
                              );
                              if (confirm == true) {
                                try {
                                  await viewModel.removerItem(item.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Removido da lista de espera com sucesso!',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao remover: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
