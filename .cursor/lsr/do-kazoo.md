# Kazoo Development Guidelines by 2600Hz

## General Principles

- **Language**: All communication and file content must be in English
- **Kazoo** — is an open-source telephony platform based on Erlang/OTP
- All Erlang/OTP principles apply (see `.cursor/lsr/do-erlang.md`)
- **Modular Architecture**: Kazoo consists of many applications (apps)
- **Microservice Architecture**: each service runs independently
- **Event-driven**: extensive use of events and AMQP for communication

## Kazoo Project Structure

### Applications (Apps)

- Each application in a separate directory (e.g., `apps/crossbar`, `apps/callflows`)
- Application structure:
  ```
  apps/app_name/
    src/               # Source code
    include/           # Header files (.hrl)
    priv/              # Private files (schemas, scripts)
    test/              # Tests
    ebin/              # Compiled modules
      app_name.app.src # Application description
      app_name.hrl     # Header file for common macro structure and application type definitions
  ```

### Main Directories

- `apps/` — all Kazoo applications
- `core/` — core libraries and utilities
- `deps/` — dependencies (rebar3)
- `rel/` — release configuration
- `config/` — configuration files

### Module Naming

- Application prefix: `app_name_module_name`. Abbreviation is allowed: crossbar_ -> cb_, coilpipe -> cpipe
- Examples: `crossbar_util`, `hon_media_util`, `kz_amqp_worker`
- Use `kz_` prefix for general Kazoo utilities

## Kazoo Architectural Patterns

### Crossbar (REST API)

- **RESTful API**: all API endpoints via Crossbar
- **Resource modules**: each resource in a separate module
- **Validation**: validation via JSON Schema
- **Authentication**: via API keys or tokens

### AMQP (Message Queue)

- **AMQP workers**: for asynchronous task processing
- **AMQP consumers**: for event processing
- **kz_amqp_worker**: base module for AMQP workers
- **kz_amqp_util**: utilities for working with AMQP

### CouchDB

- **kz_datamgr**: module for working with CouchDB
- **Views**: use CouchDB views for queries
- **Design documents**: store in `priv/couchdb/views/`
- **Schemas**: JSON Schema for document validation

### Call Control

- **Call flows**: for call management
- **kz_call**: module for working with calls
- **kz_media**: for working with media (recording, playback)
- **FreeSWITCH**: integration via ESL (Event Socket Library)

## Roles

1. **Superadmin**
2. **Reseller**
3. **Account Admin**
4. **User**

## Stubs for Kazoo

### Application Module

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

## Data Handling

### CouchDB Documents

- Use `kz_datamgr` for CRUD operations
- Always validate documents via JSON Schema
- Use `kz_doc` for working with documents
- Document types via `pvt_type` field

### JSON Schema

- Schemas in `priv/couchdb/schemas/`
- Use `kz_json_schema` for validation
- Always define schema for new document types

### Example of working with CouchDB

```erlang
-spec create_document(kz_term:ne_binary(), kz_json:object()) ->
          {'ok', kz_json:object()} | {'error', any()}.
create_document(DbName, Doc) ->
    kz_datamgr:save_doc(DbName, Doc).
```

## Testing

### EUnit Tests

- Tests in `test/` directory
- Use `kz_test_util` for testing utilities
- Mocks via `meck` for external dependencies

### Common Test

- For integration tests
- Use `kz_test_util` for environment setup

### Test Example

```erlang
-module(app_name_module_name_tests).

-include_lib("eunit/include/eunit.hrl").

function_test() ->
    ?assertEqual('ok', app_name_module_name:function()).
```

## Logging

- Use macros: `?LOG_<DEBUG|INFO|NOTICE|WARNING|ERROR|CRITICAL|ALERT|EMERGENCY>`
- **NEVER log large objects directly**: Do not print entire request/response payloads, big JSONs, or complex state records directly into the logs (e.g. `?LOG_DEBUG("req: ~p", [Req])` where `Req` contains `kapps_call` object). This pollutes the logs and creates performance issues.
- **Log specific context**: Extract and log only the necessary fields and metadata that provide context (e.g., Scenario name, Provider, Call ID, etc.).

```erlang
%% BAD: logs a huge list/object
?LOG_DEBUG("processing request: ~p", [Request])

%% GOOD: logs only relevant parts
?LOG_DEBUG("processing request for scenario ~ts with provider ~ts", [Scenario, Provider])
```

## Configuration

- Use `kapps_config` to access configuration
- Always define default values
- Read via `kapps_config:get_*` functions

## Error Handling

- Use `{ok, Value}` and `{error, Reason}` tuples
- For Crossbar: return `cb_context:add_system_error/2`
- Always log errors

## Kazoo Best Practices

### Performance

- Avoid blocking operations in processes
- Use process pools for heavy operations
- Cache frequently used data via `kz_cache`

### Security

- Always validate input data
- Use `kz_term:to_*` functions for type conversion

### Compatibility

- Follow API versioning
- Do not break existing API without migration

### Documentation

- Always document exported functions
- Use `@doc` for description
- Add usage examples in documentation
- Update API documentation on changes

## Specific Kazoo Modules

### kz_types.hrl

- Always include `kz_types.hrl` for types from app_name.hrl file
- Use types from `kz_types` instead of `term()`

### kz_term

- Utilities for working with data
- `kz_term:to_*` for conversion

### kz_json

- Working with JSON
- `kz_json:get_*` for getting values
- `kz_json:set_*` for setting values
- `kz_json:new()` for creating new object

### kz_time

- Working with time
- Always use UTC
- `kz_time:now_s()` for current time
