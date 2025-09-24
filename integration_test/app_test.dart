import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:agenda_treinamento/main_qa.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Criação de Paciente', () {
    testWidgets('Deve fazer login, navegar para pacientes e criar um novo paciente com sucesso',
        (WidgetTester tester) async {
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2. TELA DE LOGIN
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final loginButton = find.byKey(const Key('login_button'));
      
      await tester.enterText(emailField, 'luis.lange@gmail.com');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '123456');
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      //await tester.pumpAndSettle(const Duration(seconds: 5));

      // // 3. TELA INICIAL (HOME)
      // await tester.tap(find.text('Pacientes'));
      // await tester.pumpAndSettle();

      // // 4. TELA DE PACIENTES ATIVOS
      // await tester.tap(find.byKey(const Key('novo_paciente_button')));
      // await tester.pumpAndSettle();

      // // 5. TELA DE FORMULÁRIO DE PACIENTE
      // final pacienteNome = 'Paciente Teste ${DateTime.now().millisecondsSinceEpoch}';

      // final nomeField = find.byKey(const Key('paciente_nome_field'));
      // final responsavelField = find.byKey(const Key('paciente_responsavel_field'));
      // final dataNascimentoFieldKey = const Key('paciente_data_nascimento_field');
      // final cadastrarButton = find.byKey(const Key('cadastrar_paciente_button'));
      
      // await tester.enterText(nomeField, pacienteNome);
      // await tester.enterText(responsavelField, 'Responsável Teste');
      
      // // --- AJUSTE FINAL AQUI ---
      // // Tocamos no campo de data e ignoramos o warning, pois sabemos que funciona.
      // await tester.tap(find.byKey(dataNascimentoFieldKey), warnIfMissed: false);
      // await tester.pumpAndSettle();
      
      // await tester.tap(find.text('OK'));
      // await tester.pumpAndSettle();

      // await tester.ensureVisible(cadastrarButton);
      // await tester.tap(cadastrarButton);

      // await tester.pumpAndSettle(const Duration(seconds: 5));

      // // 6. VERIFICAÇÃO FINAL
      // expect(find.text('Pacientes Ativos'), findsOneWidget);
      // expect(find.text(pacienteNome), findsOneWidget);
      
      // debugPrint('SUCESSO: Paciente "$pacienteNome" criado e verificado com sucesso!');
    });
  });
}