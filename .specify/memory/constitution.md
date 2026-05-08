# AgendaNova Constitution

## Core Principles

### I. Clean Architecture Compliance
The project MUST strictly follow Clean Architecture principles. 
- **Domain Layer**: Entities and Use Cases must be pure Dart, containing all business rules.
- **Data Layer**: Repositories and Models handle external data sources (Firestore).
- **Presentation Layer**: ViewModels manage state and UI logic, never calling Repositories directly.

### II. Firestore Data Normalization & Drift
- New entities SHOULD use `Timestamp` for dates.
- **Legacy Compatibility**: The `Paciente` entity uses a specific String format (`dd/MM/yyyy`) for `dataNascimento`. Models MUST maintain this format for backward compatibility while providing `DateTime` to the domain.
- **Denormalization**: Redundant data (e.g., `pacienteNome` in `Sessao`) is allowed to optimize high-traffic queries like the calendar view.

### III. Contract Fulfillment (Non-Negotiable)
The training system is based on contract fulfillment.
- Every training MUST complete the exact number of sessions defined in `numeroSessoesTotal`.
- Cancellations or Blocks MUST trigger the "Compensação Automática" (Automatic Compensation) logic, generating extra sessions at the end of the contract cycle.

### IV. Test-First for Business Logic
- All new Use Cases MUST have corresponding unit tests in `test/domain/usecases/`.
- Success criteria defined in specifications MUST be verifiable through automated tests.

### V. Português (pt_BR) as Primary Language
- Business terms, user-facing labels, and specific Enum values (e.g., "Realizada", "Falta") MUST be in Portuguese (pt_BR).
- Technical code (variable names, classes, internal documentation) MUST be in English.

## Technology Stack
- **Framework**: Flutter (Stable)
- **Backend**: Firebase (Authentication, Cloud Firestore)
- **Dependency Injection**: GetIt
- **State Management**: ChangeNotifier / ViewModels

## Development Workflow
1. **Spec**: Update/Create YAML and MD files in `specs/`.
2. **Plan**: Define implementation steps in a feature plan.
3. **Implement**: Code the solution following Clean Architecture.
4. **Validate**: Run unit and integration tests.

**Version**: 1.0.0 | **Ratified**: 2026-05-06 | **Last Amended**: 2026-05-06
