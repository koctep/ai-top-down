# Особенности разработки на Python

## Общие принципы

- **Читаемость важнее всего**: код должен быть понятным
- **Duck typing**: "если это ходит как утка и крякает как утка, то это утка"
- **PEP 8**: следуй стандартам стиля кода
- **Zen of Python**: простота, явность, красота

## Структура проекта

- **ОБЯЗАТЕЛЬНО**: все файлы проекта должны находиться в директории `app-name/` (где `app-name` — имя приложения)
- Модули в файлах `.py`
- Пакеты через директории с `__init__.py`
- Тесты в `tests/` или `test_*.py` файлах
- Конфигурация через `config.py`, `.env` файлы или `settings/`
- `requirements.txt` или `pyproject.toml` для зависимостей
- **ОБЯЗАТЕЛЬНО**: создай файл `.gitignore` для исключения ненужных файлов из git (venv, __pycache__, .pyc, .env и т.д.)

## Архитектурные паттерны

- **MVC/MVP/MVVM**: для веб-приложений
- **Repository pattern**: для работы с данными
- **Dependency Injection**: для управления зависимостями
- **Factory pattern**: для создания объектов
- **Decorator pattern**: для расширения функциональности

## Заглушки

```python
def function_name(arg: Type) -> ReturnType:
    """
    Описание функции.

    Args:
        arg: Описание аргумента

    Returns:
        Описание возвращаемого значения

    Raises:
        NotImplementedError: Функция еще не реализована
    """
    raise NotImplementedError("Function not implemented")
```

## Тестирование

- **unittest**: стандартный фреймворк для тестов
- **pytest**: популярный альтернативный фреймворк
- **mock/unittest.mock**: для моков и стабов
- **coverage**: для измерения покрытия кода

## Типизация

- **Type hints**: используй аннотации типов (PEP 484)
- **mypy**: для статической проверки типов
- **typing модуль**: для сложных типов (List, Dict, Optional, Union и т.д.)

## Обработка ошибок

- Используй исключения (`raise Exception`)
- Обрабатывай через `try/except/finally`
- Создавай кастомные исключения когда нужно
- Используй `contextlib` для менеджеров контекста

## Виртуальное окружение

- **ОБЯЗАТЕЛЬНО**: создавай виртуальное окружение через `venv`
- **ОБЯЗАТЕЛЬНО**: создание venv должно быть автоматизировано через `Makefile`
- В `Makefile` должны быть targets: `venv` и `run`
- Пример Makefile:
  ```makefile
  .PHONY: venv run

  venv:
  	python3 -m venv venv
  	. venv/bin/activate && pip install --upgrade pip
  	. venv/bin/activate && pip install -r requirements.txt

  run:
  	. venv/bin/activate && python app-name/main.py
  ```
- Активация: `source venv/bin/activate` (Linux/Mac) или `venv\Scripts\activate` (Windows)

## .gitignore

- **ОБЯЗАТЕЛЬНО**: создай файл `.gitignore` в корне проекта
- Минимальный набор для исключения:
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

## Лучшие практики

- Используй виртуальные окружения (venv, virtualenv) — создавай через Makefile
- Следуй PEP 8 для форматирования
- Документируй через docstrings (Google style или NumPy style)
- Используй `__main__` блок для исполняемых скриптов
- Применяй list/dict comprehensions где уместно
- Используй `pathlib` вместо `os.path`
