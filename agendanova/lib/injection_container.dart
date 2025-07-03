import 'package:get_it/get_it.dart'; // Adicione get_it ao seu pubspec.yaml
import 'package:flutter_agenda_fono/core/services/firebase_service.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/repositories/agenda_disponibilidade_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/lista_espera_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/paciente_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/pagamento_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/relatorio_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/sessao_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/treinamento_repository_impl.dart';
import 'package:flutter_agenda_fono/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/lista_espera_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/paciente_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/pagamento_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/relatorio_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/sessao_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/treinamento_repository.dart';
import 'package:flutter_agenda_fono/domain/usecases/agenda/definir_agenda_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/lista_espera/adicionar_lista_espera_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/lista_espera/remover_lista_espera_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/paciente/cadastrar_paciente_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/paciente/editar_paciente_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/paciente/inativar_paciente_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/pagamento/registrar_pagamento_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/pagamento/reverter_pagamento_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/relatorio/gerar_relatorio_individual_paciente_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/relatorio/gerar_relatorio_mensal_global_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/treinamento/criar_treinamento_usecase.dart';
import 'package:flutter_agenda_fono/presentation/auth/viewmodels/login_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/pacientes/viewmodels/paciente_form_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/pagamentos/viewmodels/pagamentos_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/relatorios/viewmodels/relatorios_viewmodel.dart';
import 'package:flutter_agenda_fono/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';


final GetIt sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // Core
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
  sl.registerLazySingleton<FirebaseDatasource>(() => FirebaseDatasource(sl()));

  // Repositories
  sl.registerLazySingleton<PacienteRepository>(() => PacienteRepositoryImpl(sl()));
  sl.registerLazySingleton<ListaEsperaRepository>(() => ListaEsperaRepositoryImpl(sl()));
  sl.registerLazySingleton<AgendaDisponibilidadeRepository>(() => AgendaDisponibilidadeRepositoryImpl(sl()));
  sl.registerLazySingleton<TreinamentoRepository>(() => TreinamentoRepositoryImpl(sl()));
  sl.registerLazySingleton<SessaoRepository>(() => SessaoRepositoryImpl(sl()));
  sl.registerLazySingleton<PagamentoRepository>(() => PagamentoRepositoryImpl(sl()));
  sl.registerLazySingleton<RelatorioRepository>(() => RelatorioRepositoryImpl(sl()));


  // Use Cases
  // Pacientes
  sl.registerLazySingleton(() => CadastrarPacienteUseCase(sl()));
  sl.registerLazySingleton(() => EditarPacienteUseCase(sl()));
  sl.registerLazySingleton(() => InativarPacienteUseCase(sl()));
  sl.registerLazySingleton(() => ReativarPacienteUseCase(sl()));

  // Lista de Espera
  sl.registerLazySingleton(() => AdicionarListaEsperaUseCase(sl()));
  sl.registerLazySingleton(() => RemoverListaEsperaUseCase(sl()));

  // Agenda
  sl.registerLazySingleton(() => DefinirAgendaUseCase(sl()));

  // Treinamento
  sl.registerLazySingleton(() => CriarTreinamentoUseCase(sl(), sl(), sl(), sl()));

  // Sessão
  sl.registerLazySingleton(() => AtualizarStatusSessaoUseCase(sl(), sl(), sl()));

  // Pagamento
  sl.registerLazySingleton(() => RegistrarPagamentoUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => ReverterPagamentoUseCase(sl(), sl(), sl()));

  // Relatórios
  sl.registerLazySingleton(() => GerarRelatorioMensalGlobalUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GerarRelatorioIndividualPacienteUseCase(sl(), sl(), sl()));


  // ViewModels (Factories para que uma nova instância seja criada quando solicitada)
  sl.registerFactory(() => LoginViewModel(firebaseService: sl()));
  sl.registerFactory(() => AgendaViewModel(agendaDisponibilidadeRepository: sl()));
  sl.registerFactory(() => ListaEsperaViewModel(listaEsperaRepository: sl()));
  sl.registerFactory(() => PacientesAtivosViewModel(pacienteRepository: sl()));
  sl.registerFactory(() => PacientesInativosViewModel(pacienteRepository: sl()));
  sl.registerFactory(() => PacienteFormViewModel(pacienteRepository: sl()));
  sl.registerFactory(() => HistoricoPacienteViewModel(pacienteRepository: sl()));
  sl.registerFactory(() => PagamentosViewModel(
    pagamentoRepository: sl(),
    treinamentoRepository: sl(),
    sessaoRepository: sl(),
    pacienteRepository: sl(),
  ));
  sl.registerFactory(() => RelatoriosViewModel(
    sessaoRepository: sl(),
    treinamentoRepository: sl(),
    pacienteRepository: sl(),
  ));
  sl.registerFactory(() => SessoesViewModel(
    sessaoRepository: sl(),
    treinamentoRepository: sl(),
    agendaDisponibilidadeRepository: sl(),
  ));
}

