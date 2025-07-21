// 11ange/agendanova/AgendaNova-9b6192d7a5af5a265ec3aa3d41748ca9d26ac96a/lib/presentation/auth/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/auth/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

// Tela de Login do aplicativo
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey =
      GlobalKey<FormState>(); // Chave para o formulário de validação

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usando ChangeNotifierProvider para fornecer o LoginViewModel
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agenda de Treinamento'),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column( // Adicionado Column para empilhar o ícone e o card
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hearing,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bem-vindo!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const SizedBox(height: 24.0),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Usuário (E-mail)',
                              prefixIcon: Icon(Icons.person),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              // Não valida se os campos forem deixados vazios para permitir o bypass
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (value) {
                              // Não valida se os campos forem deixados vazios para permitir o bypass
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          Consumer<LoginViewModel>(
                            builder: (context, viewModel, child) {
                              return viewModel.isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final email = _emailController.text
                                              .trim();
                                          final password = _passwordController.text
                                              .trim();

                                          // Se ambos os campos estiverem vazios, avança sem autenticar
                                          if (email.isEmpty && password.isEmpty) {
                                            context.go('/home');
                                          } else {
                                            // Se os campos não estiverem vazios, tenta autenticar
                                            if (_formKey.currentState!.validate()) {
                                              // Captura os objetos dependentes do contexto ANTES do 'await'
                                              final navigator = GoRouter.of(context);
                                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                                              try {
                                                await viewModel.signIn(
                                                  email,
                                                  password,
                                                );
                                                // Se o login for bem-sucedido, navega para a tela inicial
                                                navigator.go('/home');
                                              } catch (e) {
                                                // Exibe mensagem de erro
                                                scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Erro de login: ${e.toString()}',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        child: const Text('Entrar'),
                                      ),
                                    );
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funcionalidade "Esqueceu a senha?" em desenvolvimento.',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Esqueceu a senha?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}