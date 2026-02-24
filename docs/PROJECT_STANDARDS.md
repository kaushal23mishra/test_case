# Project Standards

**Version**: 1.0.0  
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
 ├── core/              (constants, enums, shared utilities, extensions)
 ├── models/            (immutable data structures and domain models)
 ├── services/          (pure business logic, probability engine)
 ├── controllers/       (Riverpod state management layer)
 └── ui/                (screens, widgets, themes)
```

### 1.3 Dependency Flow (Strict)
Imports must follow a **top-down** direction only:
`ui/ → controllers/ → services/ → models/ → core/`
*   Violation of this rule breaks testability and creates circular dependencies.

### 1.4 State Management
*   **Standard**: Use **Riverpod** (`ConsumerWidget`, `NotifierProvider`).
*   One provider file per feature domain.
*   Use `ref.watch` for reactive UI, `ref.read` for one-time actions.

---

## 2. Coding Conventions

### 2.1 Language Standards
*   Use Dart 3.x features (records, patterns, sealed classes).
*   Prefer immutable data models — all model fields must be `final`.
*   Use `const` constructors wherever possible.

### 2.2 Formatting & Linting
*   Run `dart format .` before every commit.
*   Keep functions small and single-purpose (max ~40 lines).
*   Enable strict analysis (`strict-casts`, `strict-inference`).

### 2.3 Naming Conventions
*   Classes: `UpperCamelCase`
*   Variables/Functions: `lowerCamelCase`
*   Files: `snake_case.dart`
*   Providers: `lowerCamelCaseProvider`

---

## 3. Error Handling & Validation

### 3.1 Strategy
*   Use **sealed Result types** for operations that can fail.
*   Services return structured results; Controllers translate them for the UI.
*   Show user-friendly messages, never raw stack traces.

### 3.2 Model Integrity
*   Model constructors must enforce valid state (should be impossible to create an invalid instance).
*   Use `assert` in debug mode for internal invariants.

---

## 4. UI/UX Standards

### 4.1 Theme & Typography
*   Default: Dark Theme (`Color(0xFF0F172A)`).
*   Centralize colors in `AppColors` and styles in `AppTextStyles`.
*   No hardcoded hex values in widgets.

### 4.2 Performance
*   Use `const` constructors.
*   Extract frequently rebuilding sections into small, focused widgets.
*   Avoid expensive computations in `build()`.

---

## 5. Testing Standards

### 5.1 Rules
*   Every public method in the Service layer must have a Unit Test.
*   Location: `test/unit/` for logic, `test/widget/` for UI.
*   Business logic must NOT be tested through widget tests.

### 5.2 Targets
*   **Coverage**: Critical logic coverage must remain above 80%.
*   Verify all boundary cases (e.g., score thresholds).

---

## 6. Git & Workflow

### 6.1 Process
*   **Feature Branches**: All work happens on `feature/xxx` or `fix/xxx`.
*   **Commits**: Use conventional commits (`feat:`, `fix:`, `docs:`, `test:`).
*   **PRs**: Describe what, why, and impact. Review required before merge.

### 6.2 Pre-Commit Checklist
1. `dart format .`
2. `dart analyze`
3. `flutter test`
