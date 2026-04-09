## Запуск

```bash
docker compose up --build
```

## Остановка
```
docker compose down
```

## перейти в root@5ac46f3e81a0:/app#

docker compose exec web bash

В браузере:

http://localhost:3000


## Команды

Консоль Rails:

```bash
docker compose exec web bin/rails console
```

Миграции:

```bash
docker compose exec web bin/rails db:migrate
```