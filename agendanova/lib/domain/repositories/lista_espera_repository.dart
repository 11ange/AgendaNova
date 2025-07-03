import 'package:flutter_agenda_fono/domain/entities/lista_espera.dart';

// Contrato (interface) para o repositório de Lista de Espera
abstract class ListaEsperaRepository {
  // Obtém um stream de todos os itens da lista de espera, ordenados por data de cadastro
  Stream<List<ListaEspera>> getListaEspera();

  // Adiciona um novo item à lista de espera
  Future<void> adicionarListaEspera(ListaEspera item);

  // Remove um item da lista de espera pelo ID
  Future<void> removerListaEspera(String id);
}

