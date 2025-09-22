import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_treinamento/domain/entities/lista_espera.dart';

// Modelo de dados para a entidade ListaEspera, com métodos para serialização/desserialização do Firestore
class ListaEsperaModel extends ListaEspera {
  ListaEsperaModel({
    super.id,
    required super.nome,
    super.telefone,
    super.observacoes,
    required super.dataCadastro,
    super.tipoConvenio,
    required super.status,
  });

  // Construtor para criar um ListaEsperaModel a partir de um DocumentSnapshot do Firestore
  factory ListaEsperaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dataCadastro = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    return ListaEsperaModel(
      id: doc.id,
      nome: data['nome'] as String,
      telefone: data['telefone'] as String?,
      observacoes: data['observacoes'] as String?,
      dataCadastro: dataCadastro,
      tipoConvenio: data['tipoConvenio'] as String?,
      status: data['status'] as String? ?? 'aguardando', // Garante um valor padrão
    );
  }

  // Converte o ListaEsperaModel para um mapa de dados compatível com o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'telefone': telefone,
      'observacoes': observacoes,
      'timestamp': Timestamp.fromDate(dataCadastro),
      'tipoConvenio': tipoConvenio,
      'status': status,
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
      tipoConvenio: listaEspera.tipoConvenio,
      status: listaEspera.status,
    );
  }
}