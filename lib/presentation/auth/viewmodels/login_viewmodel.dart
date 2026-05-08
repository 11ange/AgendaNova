// lib/presentation/auth/viewmodels/login_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/usecases/auth/sign_in_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/auth/sign_up_usecase.dart';

// ViewModel para a tela de Login
class LoginViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  LoginViewModel(this._signInUseCase, this._signUpUseCase);

  // Realiza o processo de autenticação
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _signInUseCase.call(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Realiza o processo de cadastro
  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _signUpUseCase.call(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Define o estado de carregamento e notifica os ouvintes
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
