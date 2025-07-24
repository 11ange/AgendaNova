import 'package:agenda_treinamento/domain/entities/relatorio.dart';

// Contrato (interface) para o repositório de Relatórios
abstract class RelatorioRepository {
  // Obtém um stream de todos os relatórios (se houver necessidade de persistir relatórios gerados)
  Stream<List<Relatorio>> getRelatorios();

  // Salva um relatório gerado (opcional, dependendo se os relatórios são persistidos)
  Future<void> saveRelatorio(Relatorio relatorio);
}

