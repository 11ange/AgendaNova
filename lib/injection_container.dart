// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/core/services/firebase_service.dart';
import 'package:agenda_treinamento/data/datasources/firebase_datasource.dart';
import 'package:agenda_treinamento/data/repositories/agenda_disponibilidade_repository_impl.dart';
import 'package:agenda_treinamento/data/repositories/lista_espera_repository_impl.dart';
import 'package:agenda_treinamento/data/repositories/paciente_repository_impl.dart';
import 'package:agenda_treinamento/data/repositories/pagamento_repository_impl.dart';
import 'package:agenda_treinamento/data/repositories/relatorio_repository_impl.dart';
import 'package:agenda_treinamento/data/repositories/sessao_repository_impl.dart';
import 'package:agenda_treinamento/data/repositories/treinamento_repository_impl.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/lista_espera_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/pagamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/relatorio_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/agenda/definir_agenda_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/adicionar_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/editar_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/lista_espera/remover_lista_espera_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/cadastrar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/editar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/inativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/pagamento/registrar_pagamento_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/pagamento/reverter_pagamento_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/relatorio/gerar_relatorio_individual_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/relatorio/gerar_relatorio_mensal_global_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/treinamento/criar_treinamento_usecase.dart';
import 'package:agenda_treinamento/presentation/auth/viewmodels/login_viewmodel.dart';
import 'package:agenda_treinamento/presentation/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:agenda_treinamento/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/paciente_form_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pagamentos/viewmodels/pagamentos_viewmodel.dart';
import 'package:agenda_treinamento/presentation/relatorios/viewmodels/relatorios_viewmodel.dart';
import 'package:agenda_treinamento/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agenda_treinamento/presentation/sessoes/viewmodels/treinamento_dialog_viewmodel.dart';
import 'package:agenda_treinamento/presentation/home/viewmodels/home_viewmodel.dart';


final GetIt sl = GetIt.instance;

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
  sl.registerLazySingleton(() => CadastrarPacienteUseCase(sl()));
  sl.registerLazySingleton(() => EditarPacienteUseCase(sl()));
  sl.registerLazySingleton(() => InativarPacienteUseCase(sl(), sl()));
  sl.registerLazySingleton(() => ReativarPacienteUseCase(sl()));
  sl.registerLazySingleton(() => AdicionarListaEsperaUseCase(sl()));
  sl.registerLazySingleton(() => RemoverListaEsperaUseCase(sl()));
  sl.registerLazySingleton(() => EditarListaEsperaUseCase(sl())); // NOVO USE CASE
  sl.registerLazySingleton(() => DefinirAgendaUseCase(sl(), sl()));
  sl.registerLazySingleton(() => CriarTreinamentoUseCase(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => AtualizarStatusSessaoUseCase(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => RegistrarPagamentoUseCase(sl()));
  sl.registerLazySingleton(() => ReverterPagamentoUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GerarRelatorioMensalGlobalUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => GerarRelatorioIndividualPacienteUseCase(sl(), sl(), sl()));


  // ViewModels
  sl.registerFactory(() => LoginViewModel());
  sl.registerFactory(() => AgendaViewModel());
  sl.registerFactory(() => ListaEsperaViewModel());
  sl.registerFactory(() => PacientesAtivosViewModel());
  sl.registerFactory(() => PacientesInativosViewModel());
  sl.registerFactory(() => PacienteFormViewModel());
  sl.registerFactory(() => HistoricoPacienteViewModel());
  sl.registerFactory(() => PagamentosViewModel());
  sl.registerFactory(() => RelatoriosViewModel());
  sl.registerFactory(() => SessoesViewModel());
  sl.registerFactory(() => TreinamentoDialogViewModel());
  sl.registerFactory(() => HomeViewModel());
}