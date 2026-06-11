# Python Development Guidelines

## General Principles

- **Readability counts**: code must be understandable
- **Duck typing**: "if it walks like a duck and quacks like a duck, then it must be a duck"
- **PEP 8**: follow code style standards
- **Zen of Python**: simple, explicit, beautiful

## Project Structure

- **MANDATORY**: all project files must be located in `<APP-NAME>/` directory
- Modules in `.py` files
- Packages via directories with `__init__.py`
- Tests in `tests/` or `test_*.py` files
- Configuration via `config.py`, `.env` files or `settings/`
- `requirements.txt` or `pyproject.toml` for dependencies
- **MANDATORY**: create a `.gitignore` file to exclude unnecessary files from git (venv, __pycache__, .pyc, .env, etc.)

## Architectural Patterns

- **MVC/MVP/MVVM**: for web applications
- **Repository pattern**: for data access
- **Dependency Injection**: for dependency management
- **Factory pattern**: for object creation
- **Decorator pattern**: for extending functionality

## Stubs

```python
def function_name(arg: Type) -> ReturnType:
    """
    Function description.

    Args:
        arg: Argument description

    Returns:
        Return value description

    Raises:
        NotImplementedError: Function not yet implemented
    """
    raise NotImplementedError("Function not implemented")
```

## Testing

- **unittest**: standard testing framework
- **pytest**: popular alternative framework
- **mock/unittest.mock**: for mocks and stubs
- **coverage**: for measuring code coverage
- **MANDATORY**: every test must declare `@pytest.mark.timeout(...)` or module/class
  `pytestmark` — see `.cursor/lsr/do-testing.md` for full rules

## Typing

- **Type hints**: use type annotations (PEP 484)
- **mypy**: for static type checking
- **typing module**: for complex types (List, Dict, Optional, Union, etc.)

## Error Handling

- Use exceptions (`raise Exception`)
- Handle via `try/except/finally`
- Create custom exceptions when needed
- Use `contextlib` for context managers

## Virtual Environment

- **MANDATORY**: create virtual environment via `venv`
- **MANDATORY**: venv creation must be automated via `Makefile`
- `Makefile` must have targets: `venv` and `run`
- Example Makefile:
  ```makefile
  .PHONY: venv run

  venv:
  	python3 -m venv venv
  	. venv/bin/activate && pip install --upgrade pip
  	. venv/bin/activate && pip install -r requirements.txt

  run:
  	. venv/bin/activate && python <APP-NAME>/main.py
  ```
- Activation: `source venv/bin/activate` (Linux/Mac) or `venv\Scripts\activate` (Windows)

## .gitignore

- **MANDATORY**: create `.gitignore` file in project root
- Minimum set for exclusion:
  ```
  # Virtual environments
  venv/
  env/
  ENV/
  .venv

  # Python cache
  __pycache__/
  *.py[cod]
  *$py.class
  *.so

  # Environment variables
  .env
  .env.local

  # IDE
  .vscode/
  .idea/
  *.swp
  *.swo

  # Testing
  .pytest_cache/
  .coverage
  htmlcov/

  # Distribution
  dist/
  build/
  *.egg-info/
  ```

## Best Practices

- Use virtual environments (venv, virtualenv) — create via Makefile
- Follow PEP 8 for formatting
- Document via docstrings (Google style or NumPy style)
- Use `__main__` block for executable scripts
- Apply list/dict comprehensions where appropriate
- Use `pathlib` instead of `os.path`
