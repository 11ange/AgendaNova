import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/lista_espera.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart';
import 'package:agendanova/presentation/lista_espera/widgets/lista_espera_card.dart';
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
  final TextEditingController _searchController = TextEditingController(); // Adicionado para a busca
  List<ListaEspera> _filteredList = []; // Para armazenar a lista filtrada

  // Referência ao ViewModel
  late ListaEsperaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Acessa o ViewModel diretamente no initState, pois ele será fornecido pelo GoRouter
    _viewModel = Provider.of<ListaEsperaViewModel>(context, listen: false);

    // Escuta as mudanças no stream do ViewModel e aplica o filtro
    _viewModel.listaEsperaStream.listen((list) {
      setState(() {
        _filteredList = list;
        _applyFilter(_searchController.text); // Aplica o filtro inicial
      });
    });

    // Adiciona listener para o campo de busca
    _searchController.addListener(() {
      _applyFilter(_searchController.text);
    });
  }

  void _applyFilter(String query) {
    final originalList = _viewModel.listaEspera; // Pega a lista completa do ViewModel
    if (query.isEmpty) {
      setState(() {
        _filteredList = originalList;
      });
    } else {
      setState(() {
        _filteredList = originalList
            .where((item) => item.nome.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    _searchController.dispose(); // Dispose do controller de busca
    super.dispose();
  }

  Future<void> _showAddToListaEsperaDialog(BuildContext context, ListaEsperaViewModel viewModel) async {
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
                    validator: (value) => InputValidators.requiredField(value, 'Nome'),
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
                    telefone: _telefoneController.text.isEmpty ? null : _telefoneController.text,
                    observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
                    dataCadastro: DateTime.now(),
                  );
                  // Captura os objetos dependentes do contexto ANTES do 'await'
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogContext);
                  try {
                    await viewModel.adicionarItem(newItem);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Adicionado à lista de espera com sucesso!')),
                    );
                    navigator.pop();
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Erro ao adicionar: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) async {
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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Lista de Espera',
        onBackButtonPressed: () => context.go('/home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
              style: Theme.of(context).textTheme.bodyLarge, // Ajuste de fonte
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddToListaEsperaDialog(context, _viewModel),
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
                      return Center(child: Text('Erro ao carregar lista de espera: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('A lista de espera está vazia.'));
                    }

                    // A lista filtrada já está em _filteredList, que é atualizada pelo listener
                    final displayedList = _filteredList;

                    if (displayedList.isEmpty && _searchController.text.isNotEmpty) {
                      return const Center(child: Text('Nenhum resultado encontrado para a busca.'));
                    } else if (displayedList.isEmpty) {
                      return const Center(child: Text('A lista de espera está vazia.'));
                    }

                    return ListView.builder(
                      itemCount: displayedList.length,
                      itemBuilder: (context, index) {
                        final item = displayedList[index];
                        return ListaEsperaCard(
                          item: item,
                          onRemove: () async {
                            final confirm = await _showConfirmationDialog(context,
                                'Confirmar Remoção', 'Tem certeza que deseja remover ${item.nome} da lista de espera?');
                            if (confirm == true) {
                              // Captura o ScaffoldMessenger ANTES do 'await'
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              try {
                                await viewModel.removerItem(item.id!);
                                scaffoldMessenger.showSnackBar(
                                    const SnackBar(content: Text('Removido da lista de espera com sucesso!')));
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                    SnackBar(content: Text('Erro ao remover: $e')));
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
    );
  }
}
