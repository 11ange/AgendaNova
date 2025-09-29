import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:agenda_treinamento/main_qa.dart' as app;

class TestHelper {
  /// Limpa o banco de dados do Firestore Emulator.
  Future<void> clearDatabase() async {
    final firestoreHost = 'localhost:8080';
    const projectId = 'agenda-treinamento-testes';
    final url = Uri.http(
      firestoreHost,
      '/emulator/v1/projects/$projectId/databases/(default)/documents',
    );

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        debugPrint(
          "Banco de dados do Firestore Emulator limpo com sucesso para o projeto '$projectId'.",
        );
      } else {
        debugPrint(
          "FALHA ao limpar o Firestore Emulator. Código de Status: ${response.statusCode}. Resposta: ${response.body}",
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint(
        "ERRO DE CONEXÃO ao limpar o Firestore Emulator. Certifique-se de que ele está rodando. Erro: $e",
      );
    }
  }

  /// Inicia o aplicativo e realiza o login.
  Future<void> login(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final emailField = find.byKey(const Key('email_field'));
    expect(
      emailField,
      findsOneWidget,
      reason:
          'O campo de e-mail não foi encontrado. A tela de login pode não ter carregado a tempo.',
    );

    await tester.enterText(emailField, 'luis.lange@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('password_field')), '123456');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Clica no botão de voltar padrão da AppBar para retornar à tela anterior.
  Future<void> navigateBack(WidgetTester tester) async {
    final backButtonFinder = find.byIcon(Icons.arrow_back);

    // Espera ativa: Tenta encontrar o botão por até 10 segundos.
    bool buttonFound = false;
    for (int i = 0; i < 10; i++) {
      // pump() avança o tempo, dando chance para a UI construir.
      await tester.pump(const Duration(seconds: 1));
      // any() verifica se o widget existe, sem quebrar o teste se não encontrar.
      if (tester.any(backButtonFinder)) {
        buttonFound = true;
        break;
      }
    }

    // Se o botão não foi encontrado após a espera, o teste falha com uma mensagem clara.
    if (!buttonFound) {
      fail(
        "TIMEOUT: Botão de voltar (ícone de seta) não foi encontrado na tela atual após 10 segundos.",
      );
    }

    // Agora que temos certeza que o botão existe, podemos interagir com ele.
    await tester.tap(backButtonFinder);
    await tester.pumpAndSettle();
    debugPrint("Navegou de volta para a tela anterior com sucesso.");
  }

  /// Navega até a tela de pacientes e cria um novo paciente.
  /// Retorna o nome do paciente criado.
  Future<String> createPatient(
    WidgetTester tester, {
    String? patientName,
  }) async {
    await tester.tap(find.text('Pacientes'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('novo_paciente_button')));
    await tester.pumpAndSettle();

    final name =
        patientName ??
        'Paciente Teste ${DateTime.now().millisecondsSinceEpoch}';

    await tester.enterText(find.byKey(const Key('paciente_nome_field')), name);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('paciente_responsavel_field')),
      'Responsável Teste',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('paciente_data_nascimento_field')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('cadastrar_paciente_button')),
    );
    await tester.tap(find.byKey(const Key('cadastrar_paciente_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text(name), findsOneWidget);
    debugPrint('SUCESSO: Paciente "$name" criado e verificado!');

    return name;
  }
}
