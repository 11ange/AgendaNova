import 'package:flutter/material.dart';
import 'package:flutter_agenda_fono/core/services/firebase_service.dart';

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

  // Define o estado de carregamento e notifica os ouvintes
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

