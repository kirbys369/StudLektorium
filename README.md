# StudLektorium

## Выбранный стек

Для проекта выбран **MkDocs Material** (MkDocs + тема `material`).

## Структура документации

- `mkdocs.yml` — конфигурация сайта и навигации.
- `docs/` — контент сайта.
  - `index.md` — Главная.
  - `disciplines/index.md` — Дисциплины.
  - `guides/index.md` — Гайды.
  - `practice/index.md` — База задач / практикум.

## Локальный запуск

1. Установить зависимости:

   ```bash
   pip install mkdocs-material
   ```

2. Запустить локальный сервер:

   ```bash
   mkdocs serve
   ```

Сайт будет доступен по адресу: `http://127.0.0.1:8000`.

## Сборка

```bash
mkdocs build
```

Собранный статический сайт будет в директории `site/`.
