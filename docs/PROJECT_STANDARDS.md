# Project Standards

This document outlines the architectural patterns, coding conventions, and development standards for the **Trading Framework** project.

## 1. Architectural Patterns
*   **Separation of Concerns**: Keep business logic (trading rules) separate from the UI (Flutter widgets).
*   **Model-View-Controller (MVC) / Provider**: Use structured models for data management and state updates.
*   **Stateless by Default**: Prefer `StatelessWidget` unless state management is explicitly required.

## 2. Coding Conventions
*   **Language**: Use Dart 3.x features (Records, Patterns, Modifiers).
*   **Formatting**: Follow the official [Dart Style Guide](https://dart.dev/guides/language/evolution). Run `flutter format .` before committing.
*   **Naming Rules**:
    *   **Classes**: UpperCamelCase (e.g., `TradingFramework`).
    *   **Variables/Functions**: lowerCamelCase (e.g., `calculateScore`).
    *   **Files**: snake_case (e.g., `trading_model.dart`).

## 3. Validation Structure
*   **Input Validation**: All user inputs (price, lot size) must be validated for null or invalid types before processing.
*   **Logic Guards**: Use `if` guards to early-return in functions if parameters are missing.

## 4. UI/UX Standards
*   **Theme**: Standardize on the Dark Theme using the `Color(0xFF0F172A)` palette.
*   **Responsiveness**: Ensure the dashboard works on both mobile and tablet orientations.
*   **Feedback**: Provide visual cues (colors, icons) for different trade probability levels.

## 5. Development Workflow
*   **Git**: Meaningful commit messages are mandatory.
*   **Testing**: Maintain basic widget tests for core dashboard functionality.
