---
name: lsr-erlang
description: Erlang/OTP coding, architecture, testing, and error-handling guidance. Use for Erlang changes.
---

# Erlang/OTP Development Guidelines

## General Principles

- **Process-Oriented Architecture**: use processes as the main unit of abstraction
- **Let it crash**: processes should crash on errors, supervisors will restart them
- **Immutable Data**: all data structures are immutable
- **Pattern Matching**: main way of working with data
- **OTP Behavioral Modules**: use gen_server, gen_statem, supervisor, etc.

## Project Structure

- Modules in separate `.erl` files
- OTP applications in `src/` directory
- Tests in `test/` (EUnit) or `_test.erl` files
- Configuration in `config/` (sys.config, vm.args)
- Applications described in `.app` files

## Architectural Patterns

- **Supervisor trees**: hierarchy of supervisors to manage processes
- **Gen Server**: for stateful servers
- **Gen State Machine**: for finite state machines
- **Application**: for structuring applications
- **Release**: for deployment

## Stubs

```erlang
-module(module_name).
-export([function/1]).

%% @doc Description of the function
-spec function(Arg :: term()) -> ok | {error, Reason :: term()}.
function(_Arg) ->
    error(not_implemented).
```

## Testing

- **EUnit**: for unit tests
- **Common Test**: for integration tests
- **PropEr/QuickCheck**: for property-based testing

## Typing

- Use `-spec` to document types
- Dialyzer for static type analysis
- Types defined via `-type` and `-opaque`

## Error Handling

- Use `{ok, Value}` and `{error, Reason}` tuples
- Throw exceptions via `throw/1`, `exit/1`, `error/1`
- Supervisors handle process crashes

## Best Practices

- Avoid shared state between processes
- Use message passing for communication
- Document all exported functions
- Use supervisor for all long-lived processes
- Apply hot code reloading where possible
