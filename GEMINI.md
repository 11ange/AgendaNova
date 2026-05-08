# AgendaNova - Project Context

## Project Overview
**AgendaNova** is a Flutter application for managing auditory training schedules. It handles patient registrations, training plans, session tracking (calendar), and reporting.

## Core Architecture
- **Pattern**: Clean Architecture (Domain, Data, Presentation).
- **Entities**: Paciente, Treinamento, Sessao, Pagamento, ListaEspera, AgendaDisponibilidade, Relatorio.
- **Data Source**: Firebase (Firestore for data, Auth for user management).
- **Dependency Injection**: GetIt (`lib/injection_container.dart`).

## Key Business Rules (Recovered)
- **Automatic Compensation**: Any canceled/blocked session is automatically added to the end of the training cycle to fulfill the contract length.
- **Session Re-indexing**: Sessions are numbered (e.g., "1 of 10") and must maintain chronological order even after reschedules.
- **Patient Status**: A patient is automatically inativated when their last active training is completed and paid.
- **Smart Duplicate Detection**: Patient uniqueness is checked using a normalized name (`nomeBusca`) and Date of Birth.
  - Case-insensitive and extra spaces are ignored.
  - Matches with Archived patients are also blocked.
  - Homonyms (same name, different birth date) trigger a UI warning.
- **Archiving (Soft Delete)**: Inactive patients can be "Archived" to hide them from standard lists while preserving historical data.
- **UI Consistency**: Payment status is labeled as "**PAGO**" across all screens to distinguish it from the "**REALIZADA**" session execution status.

## Documentation & Specs
- **Entity Schemas**: Located in `specs/*.yaml`.
- **Use Cases**: Detailed flows in `specs/use_cases/*.md`.
- **Constitution**: Core development principles in `.specify/memory/constitution.md`.

## Standard Commands
- **Run**: `flutter run -d web-server` (Standard for codespaces)
- **Build**: `flutter build web`
- **Tests**: `flutter test`

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the latest plans in `.specify/memory/`.
<!-- SPECKIT END -->
