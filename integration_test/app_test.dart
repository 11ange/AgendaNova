import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
// Importe o seu main_qa para poder chamá-lo
import 'package:agenda_treinamento/main_qa.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Limpa o banco de dados do emulador antes de CADA teste
  setUp(() async {
    final firestoreHost = 'localhost:8080';
    // IMPORTANTE: Verifique se este project-id é o mesmo configurado no seu firebase.json
    const projectId = 'agenda-treinamento-6fa61';
    final url = Uri.http(
        firestoreHost, '/emulator/v1/projects/$projectId/databases/(default)/documents');
        
    try {
      final response = await http.delete(url);

      // VERIFICA SE A RESPOSTA DA API FOI DE SUCESSO
      if (response.statusCode == 200) {
        debugPrint("Banco de dados do Firestore Emulator limpo com sucesso.");
      } else {
        // Se a limpeza falhar, imprime uma mensagem de erro detalhada
        debugPrint(
            "FALHA ao limpar o Firestore Emulator. Código de Status: ${response.statusCode}. Resposta: ${response.body}");
      }
      // Adiciona uma pequena espera para garantir que a limpeza foi totalmente processada
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint(
          "ERRO DE CONEXÃO ao limpar o Firestore Emulator. Certifique-se de que ele está rodando. Erro: $e");
    }
  });

  group('Fluxo de Criação de Paciente', () {
    testWidgets('Deve fazer login, navegar para pacientes e criar um novo paciente com sucesso',
        (WidgetTester tester) async {
      
      // --- ETAPA 1: INICIALIZAÇÃO DO APP ---
      app.main();
      
      // Aguarda o app inicializar e a tela de login aparecer.
      await tester.pumpAndSettle(const Duration(seconds: 7));

      // --- ETAPA 2: INTERAÇÃO E VERIFICAÇÃO ---
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));
      
      // Verifica se o campo de e-mail está presente antes de interagir
      expect(emailField, findsOneWidget, reason: 'O campo de e-mail não foi encontrado. A tela de login pode não ter carregado a tempo.');

      await tester.enterText(emailField, 'luis.lange@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '123456');
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // TELA INICIAL (HOME)
      await tester.tap(find.text('Pacientes'));
      await tester.pumpAndSettle();

      // TELA DE PACIENTES ATIVOS
      await tester.tap(find.byKey(const Key('novo_paciente_button')));
      await tester.pumpAndSettle();

      // TELA DE FORMULÁRIO DE PACIENTE
      final pacienteNome = 'Paciente Web Teste ${DateTime.now().millisecondsSinceEpoch}';

      final nomeField = find.byKey(const Key('paciente_nome_field'));
      final responsavelField = find.byKey(const Key('paciente_responsavel_field'));
      final dataNascimentoFieldKey = const Key('paciente_data_nascimento_field');
      final cadastrarButton = find.byKey(const Key('cadastrar_paciente_button'));
      
      await tester.enterText(nomeField, pacienteNome);
      await tester.pumpAndSettle();
      await tester.enterText(responsavelField, 'Responsável Teste Web');
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(dataNascimentoFieldKey), warnIfMissed: false);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);

      // Espera a navegação de volta e a atualização da lista
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // VERIFICAÇÃO FINAL
      expect(find.text('Pacientes Ativos'), findsOneWidget);
      expect(find.text(pacienteNome), findsOneWidget);
      
      debugPrint('SUCESSO: Paciente "$pacienteNome" criado e verificado!');
    });
  });
}

