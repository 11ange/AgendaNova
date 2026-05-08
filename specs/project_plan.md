# Project Plan: AgendaNova Brownfield Recovery

## Current State (Post-Recovery)
The project has been fully audited and synchronized.
- [x] **Entity Specs**: All 8 entities mapped to YAML.
- [x] **Use Case Specs**: 6 core use case documents created/updated.
- [x] **Constitution**: Established project-specific coding and business standards.
- [x] **Logic Consolidation**: Removed redundant code in the use case layer.
- [x] **Critical Bug Fixes**: Aligned date handling and enum values across specs and code.

## Known Technical Debt
- **Auth Layer**: Currently bypasses Use Cases. Should be refactored to use standard patterns.
- **Testing**: `Relatorio` and `ListaEspera` modules need full test suites.
- **UI State**: Some ViewModels contain direct Firestore logic that should be moved to Use Cases.

## Roadmap
- [x] **Refactor Auth**: Wrapped `FirebaseService` calls in `SignInUseCase`, `SignUpUseCase`, and `SignOutUseCase`.
- [x] **DI Overhaul**: Migrated all ViewModels to Constructor Injection for better testability.
2. **Expand Coverage**: Implement unit tests for all remaining Use Cases.
3. **UI Modernization**: Review and polish the presentation layer (CSS/Theming).
4. **New Feature**: "Export to PDF" for Individual Patient Reports.

## Maintenance
- Specifications MUST be updated before any change to entities or business rules.
- Run `flutter test` after every modification to ensure contract fulfillment logic remains intact.
