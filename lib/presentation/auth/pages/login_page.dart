// lib/presentation/auth/pages/login_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/auth/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:agendanova/core/utils/snackbar_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey =
      GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
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
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira um e-mail.';
                              }
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
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira uma senha.';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter no mínimo 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32.0),
                          Consumer<LoginViewModel>(
                            builder: (context, viewModel, child) {
                              if (viewModel.isLoading) {
                                return const CircularProgressIndicator();
                              }
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (kDebugMode && _emailController.text.isEmpty && _passwordController.text.isEmpty) {
                                           context.go('/home');
                                           return;
                                        }

                                        if (_formKey.currentState!.validate()) {
                                          final email = _emailController.text.trim();
                                          final password = _passwordController.text.trim();
                                          try {
                                            await viewModel.signIn(email, password);
                                            if (!context.mounted) return;
                                            context.go('/home');
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            SnackBarHelper.showError(context, e);
                                          }
                                        }
                                      },
                                      child: const Text('Entrar'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          final email = _emailController.text.trim();
                                          final password = _passwordController.text.trim();
                                          try {
                                            await viewModel.signUp(email, password);
                                            if (!context.mounted) return;
                                            SnackBarHelper.showSuccess(context, 'Usuário criado com sucesso! Por favor, faça o login.');
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            SnackBarHelper.showError(context, e);
                                          }
                                        }
                                      },
                                      child: const Text('Cadastrar Novo Usuário'),
                                    ),
                                  ),
                                ],
                              );
                            },
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