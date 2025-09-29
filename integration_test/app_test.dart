import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final helper = TestHelper();

  // Limpa o banco antes de CADA teste neste arquivo
  setUp(() async {
    await helper.clearDatabase();
  });

  group('Fluxo Basico - ', () {
    testWidgets('Criar Paciente 1', (WidgetTester tester) async {
      // ETAPA 1: Login
      await helper.login(tester);
      debugPrint("Login realizado com sucesso.");

      // ETAPA 2: Criar Paciente
      const pacienteNome = 'Paciente de Teste Simples';
      await helper.createPatient(tester, patientName: pacienteNome);
      debugPrint("Paciente criado com sucesso.");
      await helper.navigateBack(tester);
      //const pacienteNome = 'Paciente de Teste Simples';
      //await helper.createPatient(tester, patientName: pacienteNome);
      debugPrint("Fluxo de criação de paciente executado.");
    });
  });
}
