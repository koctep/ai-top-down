# Особенности разработки на JavaScript

## Общие принципы

- **ES6+ features**: используй современный синтаксис
- **Functional programming**: применяй функциональные подходы где уместно
- **Async/await**: для асинхронного кода
- **Modularity**: разбивай код на модули

## Структура проекта

- Модули в файлах `.js` или `.mjs`
- Конфигурация в `package.json`, `.eslintrc`, `.prettierrc`
- Тесты в `*.test.js` или `*.spec.js` файлах
- `node_modules/` для зависимостей (npm/yarn/pnpm)

## Архитектурные паттерны

- **MVC/MVP/MVVM**: для веб-приложений
- **Component pattern**: для UI компонентов
- **Module pattern**: для инкапсуляции
- **Observer pattern**: для событий
- **Factory pattern**: для создания объектов

## Заглушки

```javascript
/**
 * Описание функции
 * @param {Type} arg - Описание аргумента
 * @returns {ReturnType} Описание возвращаемого значения
 * @throws {Error} Описание исключения
 */
function functionName(arg) {
    throw new Error('Not implemented');
}
```

## Тестирование

- **Jest**: популярный фреймворк для тестов
- **Mocha + Chai**: альтернативный стек
- **Vitest**: быстрый современный фреймворк
- **@testing-library**: для тестирования UI

## Типизация

- Используй JSDoc комментарии для типов (`@param {Type}`, `@returns {Type}`)
- Применяй TypeScript для новых проектов (лучше чем plain JS)
- Используй PropTypes для React компонентов
- Применяй runtime валидацию (Joi, Yup, Zod)

## Обработка ошибок

- Используй `throw new Error()` для исключений
- Обрабатывай через `try/catch/finally`
- Создавай кастомные классы ошибок
- Используй промисы с `.catch()` для асинхронных операций

## Лучшие практики

- Используй `const` и `let`, избегай `var`
- Применяй async/await вместо промисов где возможно
- Используй деструктуризацию
- Применяй arrow functions для коротких функций
- Используй optional chaining (`?.`) и nullish coalescing (`??`)
- Экспортируй через `export`/`import` (ES modules), избегай `require` где возможно
- Используй `===` вместо `==`
- Применяй template literals для строк

