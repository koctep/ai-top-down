---
name: lsr-flutter
description: Flutter and Dart coding, architecture, testing, and documentation guidance. Use for Flutter changes.
---

# Flutter Development Guidelines

For Flutter documentation guidance, read
[references/documentation.md](references/documentation.md).

## General Principles

- **Everything is a Widget**: Embrace the widget tree structure.
- **Composition over Inheritance**: Build complex UIs by composing simple widgets rather than inheritance hierarchies.
- **State Management**: Use established patterns (BLoC, Provider, Riverpod) consistently; avoid mixing patterns without reason.
- **Declarative UI**: UI reflects the current state; update state to update UI.

## Project Structure

- `lib/main.dart`: Application entry point.
- `lib/src/`: Core source code.
- `lib/src/features/`: Feature-based organization (e.g., `auth`, `profile`, `feed`).
- `lib/src/core/`: Shared utilities, constants, and widgets.
- `test/`: Unit and widget tests corresponding to `lib/` structure.
- `pubspec.yaml`: Dependency management and asset declaration.
- `analysis_options.yaml`: Linter rules configuration.

## Architectural Patterns

- **BLoC / Cubit**: Preferred for complex state management and separating business logic from UI.
- **Provider / Riverpod**: Excellent for dependency injection and simpler state management needs.
- **Repository Pattern**: Abstract data access to decouple the app from specific data sources (API, Database).
- **Clean Architecture**: Separation of layers (Domain, Data, Presentation) for scalability.

## Stubs

### Stateless Widget Stub

```dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

### Function Stub

```dart
/// Performs a specific action.
///
/// Throws [UnimplementedError] if not yet implemented.
Future<void> doSomething() async {
  throw UnimplementedError('doSomething not implemented');
}
```

## Testing

- **Unit Tests**: Use `test` package for logic and repositories.
- **Widget Tests**: Use `testWidgets` for UI components and interactions.
- **Integration Tests**: Use `integration_test` for end-to-end flows.
- **Golden Tests**: For pixel-perfect visual regression testing.
- **Mocking**: Use `mockito` or `mocktail` for dependencies.

## Typing

- **Strong Typing**: Explicitly define types for public APIs.
- **Null Safety**: Strictly follow null safety; avoid `!` unless absolutely certain.
- **Type Inference**: Use `var` or `final` for local variables where type is obvious.
- **Generics**: Use generics for reusable components and data structures.

## Error Handling

- **Try/Catch**: Wrap risky synchronous code blocks.
- **runZonedGuarded**: Catch global unhandled errors.
- **ErrorWidget**: Customize the error screen for release builds.
- **Result Types**: Consider using `fpdart` or `dartz` `Either` type for functional error handling.

## Best Practices

- **Const Constructors**: Always use `const` for widgets and values where possible to optimize rebuilds.
- **Linting**: Enforce strict rules using `analysis_options.yaml` (e.g., `very_good_analysis`).
- **Small Build Methods**: Extract complex widget trees into separate classes, not helper methods.
- **Keys**: Use keys (`ValueKey`, `ObjectKey`) appropriately when working with lists and state preservation.
- **Async/Await**: Use `async`/`await` for readable asynchronous code; avoid `.then()` chains.
- **Resource Disposal**: Always dispose `Controllers` (TextEditingController, AnimationController) in `dispose()`.
