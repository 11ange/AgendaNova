// Mocks generated by Mockito 5.4.6 from annotations
// in agendanova/test/domain/usecases/paciente/cadastrar_paciente_usecase_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:agenda_treinamento/domain/entities/paciente.dart' as _i4;
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [PacienteRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockPacienteRepository extends _i1.Mock
    implements _i2.PacienteRepository {
  MockPacienteRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<List<_i4.Paciente>> getPacientes() =>
      (super.noSuchMethod(
            Invocation.method(#getPacientes, []),
            returnValue: _i3.Stream<List<_i4.Paciente>>.empty(),
          )
          as _i3.Stream<List<_i4.Paciente>>);

  @override
  _i3.Stream<List<_i4.Paciente>> getPacientesAtivos() =>
      (super.noSuchMethod(
            Invocation.method(#getPacientesAtivos, []),
            returnValue: _i3.Stream<List<_i4.Paciente>>.empty(),
          )
          as _i3.Stream<List<_i4.Paciente>>);

  @override
  _i3.Stream<List<_i4.Paciente>> getPacientesInativos() =>
      (super.noSuchMethod(
            Invocation.method(#getPacientesInativos, []),
            returnValue: _i3.Stream<List<_i4.Paciente>>.empty(),
          )
          as _i3.Stream<List<_i4.Paciente>>);

  @override
  _i3.Future<_i4.Paciente?> getPacienteById(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getPacienteById, [id]),
            returnValue: _i3.Future<_i4.Paciente?>.value(),
          )
          as _i3.Future<_i4.Paciente?>);

  @override
  _i3.Future<void> addPaciente(_i4.Paciente? paciente) =>
      (super.noSuchMethod(
            Invocation.method(#addPaciente, [paciente]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> updatePaciente(_i4.Paciente? paciente) =>
      (super.noSuchMethod(
            Invocation.method(#updatePaciente, [paciente]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> inativarPaciente(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#inativarPaciente, [id]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> reativarPaciente(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#reativarPaciente, [id]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<bool> pacienteExistsByName(String? nome, {String? excludeId}) =>
      (super.noSuchMethod(
            Invocation.method(
              #pacienteExistsByName,
              [nome],
              {#excludeId: excludeId},
            ),
            returnValue: _i3.Future<bool>.value(false),
          )
          as _i3.Future<bool>);
}
