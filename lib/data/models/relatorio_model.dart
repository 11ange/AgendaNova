import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_treinamento/domain/entities/relatorio.dart';

// Modelo de dados para a entidade Relatorio, com métodos para serialização/desserialização do Firestore
class RelatorioModel extends Relatorio {
  RelatorioModel({
    required super.id,
    required super.tipoRelatorio,
    required super.dataGeracao,
    required super.dados,
  });

  // Construtor para criar um RelatorioModel a partir de um DocumentSnapshot do Firestore
  factory RelatorioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RelatorioModel(
      id: doc.id,
      tipoRelatorio: data['tipoRelatorio'] as String,
      dataGeracao: (data['dataGeracao'] as Timestamp).toDate(),
      dados: data['dados'] as Map<String, dynamic>,
    );
  }

  // Converte o RelatorioModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'tipoRelatorio': tipoRelatorio,
      'dataGeracao': Timestamp.fromDate(dataGeracao),
      'dados': dados,
    };
  }

  // Construtor para criar um RelatorioModel a partir de uma entidade Relatorio
  factory RelatorioModel.fromEntity(Relatorio relatorio) {
    return RelatorioModel(
      id: relatorio.id,
      tipoRelatorio: relatorio.tipoRelatorio,
      dataGeracao: relatorio.dataGeracao,
      dados: relatorio.dados,
    );
  }
}
