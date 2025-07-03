import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendanova/domain/entities/lista_espera.dart';

// Modelo de dados para a entidade ListaEspera, com métodos para serialização/desserialização do Firestore
class ListaEsperaModel extends ListaEspera {
  ListaEsperaModel({
    String? id,
    required String nome,
    String? telefone,
    String? observacoes,
    required DateTime dataCadastro,
  }) : super(
          id: id,
          nome: nome,
          telefone: telefone,
          observacoes: observacoes,
          dataCadastro: dataCadastro,
        );

  // Construtor para criar um ListaEsperaModel a partir de um DocumentSnapshot do Firestore
  factory ListaEsperaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Lê do campo 'timestamp' no Firestore, tratando como opcional
    final dataCadastro = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    return ListaEsperaModel(
      id: doc.id,
      nome: data['nome'] as String,
      telefone: data['telefone'] as String?,
      observacoes: data['observacoes'] as String?,
      dataCadastro: dataCadastro,
    );
  }

  // Converte o ListaEsperaModel para um mapa de dados compatível com o Firestore
  @override
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'telefone': telefone,
      'observacoes': observacoes,
      'timestamp': Timestamp.fromDate(dataCadastro), // Salva no campo 'timestamp'
    };
  }

  // Construtor para criar um ListaEsperaModel a partir de uma entidade ListaEspera
  factory ListaEsperaModel.fromEntity(ListaEspera listaEspera) {
    return ListaEsperaModel(
      id: listaEspera.id,
      nome: listaEspera.nome,
      telefone: listaEspera.telefone,
      observacoes: listaEspera.observacoes,
      dataCadastro: listaEspera.dataCadastro,
    );
  }
}
