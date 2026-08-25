---
name: lsr-typescript
description: TypeScript coding, architecture, testing, and error-handling guidance. Use for TypeScript changes.
---

# TypeScript Development Guidelines

## General Principles

- **Type safety**: use types for code safety
- **Strict mode**: enable strict compilation mode
- **ES6+ features**: use modern JavaScript capabilities
- **Modularity**: break code into modules

## Project Structure

- Modules in `.ts` files
- Configuration in `tsconfig.json`
- Tests in `*.test.ts` or `*.spec.ts` files
- Types in `types/` or `@types/` directories
- `package.json` for dependencies and scripts

## Architectural Patterns

- **MVC/MVP/MVVM**: for web applications
- **Component pattern**: for UI components
- **Dependency Injection**: for dependency management
- **Observer pattern**: for events
- **Factory pattern**: for creating objects

## Stubs

```typescript
/**
 * Function description
 * @param arg - Argument description
 * @returns Return value description
 * @throws {Error} Exception description
 */
function functionName(arg: Type): ReturnType {
    throw new Error('Not implemented');
}
```

## Testing

- **Jest**: popular framework for tests
- **Mocha + Chai**: alternative stack
- **Vitest**: fast modern framework
- **@testing-library**: for UI testing

## Typing

- Use explicit types for all functions
- Apply `interface` and `type` for data structures
- Use generics for reusable code
- Apply `enum` for constants
- Use `readonly` for immutable data

## Error Handling

- Use `throw new Error()` for exceptions
- Handle via `try/catch/finally`
- Create custom error classes
- Use `Result<T, E>` pattern where appropriate

## Best Practices

- Enable `strict: true` in tsconfig.json
- Use `const` and `let`, avoid `var`
- Apply async/await instead of promises where possible
- Use destructuring
- Apply arrow functions for short functions
- Use optional chaining (`?.`) and nullish coalescing (`??`)
- Export via `export`/`import`, avoid `require`
