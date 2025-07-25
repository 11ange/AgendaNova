// lib/presentation/auth/viewmodels/login_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:agenda_treinamento/core/services/firebase_service.dart';

// ViewModel para a tela de Login
class LoginViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  LoginViewModel({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  // Realiza o processo de autenticação
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _firebaseService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      // Relança a exceção para que a UI possa lidar com ela
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // NOVO MÉTODO: Realiza o processo de cadastro
  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _firebaseService.createUserWithEmailAndPassword(email, password);
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