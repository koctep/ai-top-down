# Особенности разработки для Kazoo by 2600Hz

## Общие принципы

- **Kazoo** — это open-source платформа для телефонии на базе Erlang/OTP
- Все принципы Erlang/OTP применяются (см. `.cursor/lsr/do-erlang.md`)
- **Модульная архитектура**: Kazoo состоит из множества приложений (apps)
- **Микросервисная архитектура**: каждый сервис работает независимо
- **Event-driven**: широкое использование событий и AMQP для коммуникации

## Структура проекта Kazoo

### Приложения (Apps)

- Каждое приложение в отдельной директории (например, `apps/crossbar`, `apps/callflows`)
- Структура приложения:
  ```
  apps/app_name/
    src/               # Исходный код
    include/           # Заголовочные файлы (.hrl)
    priv/              # Приватные файлы (схемы, скрипты)
    test/              # Тесты
    ebin/              # Скомпилированные модули
      app_name.app.src # Описание приложения
      app_name.hrl     # Заголовочный файл для общей структуры макросов и определений типов приложения
  ```

### Основные директории

- `apps/` — все приложения Kazoo
- `core/` — основные библиотеки и утилиты
- `deps/` — зависимости (rebar3)
- `rel/` — конфигурация релиза
- `config/` — конфигурационные файлы

### Именование модулей

- Префикс приложения: `app_name_module_name`. Допускается сокращать crossbar_ -> cb_, coilpipe -> cpipe
- Примеры: `crossbar_util`, `hon_media_util`, `kz_amqp_worker`
- Используй `kz_` префикс для общих утилит Kazoo

## Архитектурные паттерны Kazoo

### Crossbar (REST API)

- **RESTful API**: все API endpoints через Crossbar
- **Resource modules**: каждый ресурс в отдельном модуле
- **Validation**: валидация через схемы JSON Schema
- **Authentication**: через API keys или tokens

### AMQP (Message Queue)

- **AMQP workers**: для асинхронной обработки задач
- **AMQP consumers**: для обработки событий
- **kz_amqp_worker**: базовый модуль для AMQP workers
- **kz_amqp_util**: утилиты для работы с AMQP

### CouchDB

- **kz_datamgr**: модуль для работы с CouchDB
- **Views**: используй CouchDB views для запросов
- **Design documents**: храни в `priv/couchdb/views/`
- **Schemas**: JSON Schema для валидации документов

### Call Control

- **Call flows**: для управления звонками
- **kz_call**: модуль для работы со звонками
- **kz_media**: для работы с медиа (запись, воспроизведение)
- **FreeSWITCH**: интеграция через ESL (Event Socket Library)

## Заглушки для Kazoo

### Модуль приложения

### Crossbar Resource

```erlang
-module(cb_resource_name).
-behaviour(cb_modules).

-export([init/0
        ,allowed_methods/0
        ,resource_exists/0
        ,validate/1
        ,post/1
        ,delete/1
        ]).

-include("crossbar.hrl").

-spec init() -> 'ok'.
init() ->
    _ = crossbar_bindings:bind(<<"*.allowed_methods.resource_name">>, ?MODULE, 'allowed_methods'),
    _ = crossbar_bindings:bind(<<"*.resource_exists.resource_name">>, ?MODULE, 'resource_exists'),
    _ = crossbar_bindings:bind(<<"*.validate.resource_name">>, ?MODULE, 'validate'),
    _ = crossbar_bindings:bind(<<"*.execute.post.resource_name">>, ?MODULE, 'post'),
    _ = crossbar_bindings:bind(<<"*.execute.delete.resource_name">>, ?MODULE, 'delete'),
    'ok'.

-spec allowed_methods() -> http_methods().
allowed_methods() ->
    [?HTTP_GET, ?HTTP_POST, ?HTTP_DELETE].

-spec resource_exists() -> 'true'.
resource_exists() ->
    'true'.

-spec validate(cb_context:context()) -> cb_context:context().
validate(Context) ->
    validate_request(Context).

-spec post(cb_context:context()) -> cb_context:context().
post(Context) ->
    error('not_implemented').

-spec delete(cb_context:context()) -> cb_context:context().
delete(Context) ->
    error('not_implemented').
```

## Работа с данными

### CouchDB документы

- Используй `kz_datamgr` для CRUD операций
- Всегда валидируй документы через JSON Schema
- Используй `kz_doc` для работы с документами
- Типы документов через поле `pvt_type`

### JSON Schema

- Схемы в `priv/couchdb/schemas/`
- Используй `kz_json_schema` для валидации
- Всегда определяй схему для новых типов документов

### Пример работы с CouchDB

```erlang
-spec create_document(kz_term:ne_binary(), kz_json:object()) -> 
          {'ok', kz_json:object()} | {'error', any()}.
create_document(DbName, Doc) ->
    kz_datamgr:save_doc(DbName, Doc).
```

## Тестирование

### EUnit тесты

- Тесты в `test/` директории
- Используй `kz_test_util` для утилит тестирования
- Моки через `meck` для внешних зависимостей

### Common Test

- Для интеграционных тестов
- Используй `kz_test_util` для настройки окружения

### Пример теста

```erlang
-module(app_name_module_name_tests).

-include_lib("eunit/include/eunit.hrl").

function_test() ->
    ?assertEqual('ok', app_name_module_name:function()).
```

## Логирование

- Используй макросы: `?LOG_<DEBUG|INFO|NOTICE|WARNING|ERROR|CRITICAL|ALERT|EMERGENCY>`
// TODO: описать правила логгирования

```erlang
?LOG_DEBUG("processing request: ~p", [Request])
```

## Конфигурация

- Используй `kapps_config` для доступа к конфигурации
- Всегда определяй значения по умолчанию
- Читай через `kapps_config:get_*` функции

## Обработка ошибок

- Используй `{ok, Value}` и `{error, Reason}` tuples
- Для Crossbar: возвращай `cb_context:add_system_error/2`
- Всегда логируй ошибки

## Лучшие практики Kazoo

### Производительность

- Избегай блокирующих операций в процессах
- Используй пулы процессов для тяжелых операций
- Кэшируй часто используемые данные через `kz_cache`

### Безопасность

- Всегда валидируй входные данные
- Используй `kz_term:to_*` функции для конвертации типов

### Совместимость

- Следуй версионированию API
- Не ломай существующие API без миграции

### Документация

- Всегда документируй экспортируемые функции
- Используй `@doc` для описания
- Добавляй примеры использования в документации
- Обновляй API документацию при изменениях

## Специфичные модули Kazoo

### kz_types.hrl

- Всегда включай `kz_types.hrl` для типов из файла app_name.hrl
- Используй типы из `kz_types` вместо `term()`

### kz_term

- Утилиты для работы с данными
- `kz_term:to_*` для конвертации

### kz_json

- Работа с JSON
- `kz_json:get_*` для получения значений
- `kz_json:set_*` для установки значений
- `kz_json:new()` для создания нового объекта

### kz_time

- Работа со временем
- Всегда используй UTC
- `kz_time:now_s()` для текущего времени
