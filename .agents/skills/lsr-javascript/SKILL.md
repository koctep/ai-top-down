---
name: lsr-javascript
description: JavaScript coding, architecture, testing, and error-handling guidance. Use for JavaScript changes.
---

# JavaScript Development Guidelines

## General Principles

- **ES6+ features**: use modern syntax
- **Functional programming**: apply functional approaches where appropriate
- **Async/await**: for asynchronous code
- **Modularity**: break code into modules

## Project Structure

- Modules in `.js` or `.mjs` files
- Configuration in `package.json`, `.eslintrc`, `.prettierrc`
- Tests in `*.test.js` or `*.spec.js` files
- `node_modules/` for dependencies (npm/yarn/pnpm)

## Architectural Patterns

- **MVC/MVP/MVVM**: for web applications
- **Component pattern**: for UI components
- **Module pattern**: for encapsulation
- **Observer pattern**: for events
- **Factory pattern**: for creating objects

## Stubs

```javascript
/**
 * Function description
 * @param {Type} arg - Argument description
 * @returns {ReturnType} Return value description
 * @throws {Error} Exception description
 */
function functionName(arg) {
    throw new Error('Not implemented');
}
```

## Testing

- **Jest**: popular framework for tests
- **Mocha + Chai**: alternative stack
- **Vitest**: fast modern framework
- **@testing-library**: for UI testing

## Typing

- Use JSDoc comments for types (`@param {Type}`, `@returns {Type}`)
- Use TypeScript for new projects (better than plain JS)
- Use PropTypes for React components
- Apply runtime validation (Joi, Yup, Zod)

## Error Handling

- Use `throw new Error()` for exceptions
- Handle via `try/catch/finally`
- Create custom error classes
- Use promises with `.catch()` for asynchronous operations

## Best Practices

- Use `const` and `let`, avoid `var`
- Apply async/await instead of promises where possible
- Use destructuring
- Apply arrow functions for short functions
- Use optional chaining (`?.`) and nullish coalescing (`??`)
- Export via `export`/`import` (ES modules), avoid `require` where possible
- Use `===` instead of `==`
- Apply template literals for strings
