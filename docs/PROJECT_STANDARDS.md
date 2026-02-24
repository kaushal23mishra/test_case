# Project Standards

**Version**: 1.5.0  
**Status**: Active  
**Last Updated**: 2026-02-24

---

## 1. Architecture Principles

### 1.1 Separation of Concerns
*   Business logic must remain completely independent from UI components.
*   UI layers must only consume processed data exposed by controllers or services.
*   No direct data manipulation inside widgets.

### 1.2 Layered Structure
```
lib/
 ├── core/              (constants, enums, shared utilities, config)
 │    ├── constants/     (app-wide defaults like kDoubleTolerance)
 │    ├── config/        (engine weights, thresholds, scoring rules)
 │    └── utils/         (logging, formatting, validators)
 ├── models/            (immutable data structures)
 ├── services/          (pure business logic, probability engine)
 ├── repositories/      (async data sources, persistence, API)
 ├── controllers/       (Riverpod state management layer)
 └── ui/                (screens, widgets, themes)
```

### 1.3 Layer Responsibilities
*   **Services** must be **pure, sync, and side-effect free**.
    *   No logging, no navigation, no UI access, no state mutation outside their scope.
    *   **No Async**: Services must not perform network calls or database access.
    *   **Determinism Lock**: Services must not depend on `DateTime.now()`, random values, or external mutable state. All required data must be provided as input parameters.
*   **Repositories** handle all asynchronous I/O and data persistence.
*   **Controllers** orchestrate services/repositories and manage state. 
    *   **Logging**: Controllers are responsible for logging evaluation results.
    *   Logging Level: Use `Info` for final decisions, `Debug/Fine` for full evaluation breakdowns.
*   **UI** must never compute business logic inside `build()`.
*   **State Management (Riverpod)**:
    *   Use `ref.watch` for anything that affects the UI rendering.
    *   Use `ref.read` ONLY inside callbacks (like `onPressed`) or for initializing one-time actions.
    *   Keep Providers small and focused on a single piece of state.

### 1.4 Dependency Flow (Strict)
Imports must follow a **top-down** direction only:
`ui/ → controllers/ → repositories/ → services/ → models/ → core/`
*   **Tooling**: Use `import_lint` or similar analysis to enforce these boundaries.
*   Violation breaks testability and creates circular dependencies.

---

## 2. Coding Conventions

### 2.1 Language Standards
*   Use Dart 3.x features (records, sealed classes).
*   **Extensions**: Must not contain decision-making business logic.
*   Prefer immutable models — all fields must be `final`.

### 2.2 Formatting & Linting
*   Run `dart format .` before every commit.
*   **Zero-Warning Policy**: `flutter analyze --fatal-infos --fatal-warnings` must report 0 issues.
*   **Strict Mode**: Any info, warning, or lint violation is considered a build-blocking error.
*   **Logging Discipline**:
    *   Use the centralized `log` instance from `core/utils/logger_utils.dart`.
    *   **Level INFO**: For final results, state transitions, or major user actions.
    *   **Level SEVERE**: For errors that stop a process.
    *   **NO print()**: Use `log` or `debugPrint`. The analyzer will block `print`.
*   **Analyzer Configuration**:
    *   `strict-casts: true`: Prevents implicit downcasts from `dynamic`.
    *   `strict-inference: true`: Forces explicit types where inference might fail or be too broad.
    *   `strict-raw-types: true`: Generic types must never be raw (e.g., use `List<String>` instead of `List`).
    *   `always_use_package_imports: error`: Forces `package:project_name/` style; no relative imports.
    *   `unawaited_futures: true`: All futures must be awaited or explicitly marked (e.g., using `unawaited()`).

### 2.3 Import Style
*   All imports within `lib/` must use **absolute `package:` imports**.
*   Relative imports (`../`) are strictly prohibited.

### 2.4 Naming & Strings
*   **No Hardcoded Labels**: Business logic labels (Grade A, etc.) must be defined in `core/config/engine_config.dart`.
*   Naming: `UpperCamelCase` for Classes, `lowerCamelCase` for Variables/Functions.

---

## 3. Error Handling & Validation

### 3.1 Strategy
*   Use **sealed Result types** for operations that can fail.
*   Never silently swallow errors — always log or propagate.

### 3.2 Numeric Precision
*   Use `double` for indicators. Never compare with `==`.
*   Use `(a - b).abs() < kDoubleTolerance` defined in `core/constants/`.

---

## 4. Trading Logic Standards (The Contract)

### 4.1 Deterministic Scoring
*   All parameter weights and thresholds must reside in `lib/core/config/engine_config.dart`.
*   **Dynamic Denominator**: The total possible score must be derived from the sum of weights, not hardcoded.
*   **Serializable Core**: Engine evaluation results must be serializable (e.g., `toJson()`).

### 4.2 Hard Filters
*   Must be evaluated **before** scoring logic.
*   **Short-Circuit**: A failed hard filter must stop calculation and skip normalization.

### 4.3 Engine Versioning
Any change to weights or thresholds requires:
1. Increment the project minor version (e.g., 1.2 → 1.3).
2. Update `docs/CHANGELOG.md` with "ENGINE CHANGE" tag.
3. Update boundary tests.
4. **Enforcement**: PRs modifying logic without changelog updates must be rejected.

---

## 5. UI/UX Standards

### 5.1 Color Mapping
*   **High (Grade A)** → Green
*   **Medium (Grade B)** → Orange (Updated from Yellow for better contrast)
*   **Low (Grade C)** → Red

---

## 6. Testing & CI

### 6.1 Requirements
*   Every public Service method must have Unit Tests.
*   **Coverage**: Critical service logic must maintain **>80% coverage**.
*   **Quality Gate**: Use `./test_agent.sh` for local validation before pushing.

---

### 6.2 Final Verification (Smoke Test)
*   **Tests are not enough**: Passing unit and widget tests is a baseline, but not a guarantee of a working app.
*   **Mandatory Run**: After all tests pass, the application must be successfully built and run (Hot Restart) to verify there are no runtime crashes or initialization errors.
*   **Automated Smoke Test**: Run `test/smoke_test.dart` to verify app initialization and basic navigation.
*   **Sign-off**: A feature is only considered "Done" when it passes tests AND the automated smoke test suite.
*   **Test Stability (Native Plugins)**: 
    *   Widgets using native-only plugins (like WebView) must provide a fallback for test environments.
    *   Example: `if (kDebugMode && someTestingFlag) return SizedBox();`
    *   This ensures the "Smoke Test" can mount the entire tree without a physical device.

---

## 7. Git & Workflow
*   **Conventional Commits**: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`.
*   **PR Review**: Description must state if an "ENGINE CHANGE" is included.
*   Reviewer Checklist: Verify dependency flow and sync-purity of services.

---

## 8. Quality Gate Enforcement (Tooling)

### 8.1 `./test_agent.sh`
This script is the project's gatekeeper. It performs the following checks in order:
1.  **Static Analysis**: Runs `flutter analyze --fatal-infos --fatal-warnings`.
2.  **Audit**: Discovers all `*_test.dart` files and ensures they are accounted for.
3.  **Test Run**: Executes the entire test suite (Unit, Widget, Global, Smoke).
4.  **Integrity**: Blocks the process if any test file was skipped or failed.
5.  **Silent on Success**: Success output MUST be concise. Individual test cases should NOT be listed unless they fail.

**Mandatory Usage**: Every developer MUST run `./test_agent.sh` before pushing code.
