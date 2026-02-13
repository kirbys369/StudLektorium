# Деплой StudLektorium на Ubuntu + Nginx + Let's Encrypt

Ниже — базовый сценарий развёртывания MkDocs-сайта и настройки HTTPS.

## 1) Подготовка сервера

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y nginx python3 python3-pip git
```

## 2) Базовое усиление безопасности

В репозитории подготовлены скрипты:

- `infra/scripts/create_user.sh` — создание deploy-пользователя и установка SSH-ключа.
- `infra/scripts/ssh_hardening.sh` — отключение root/password входа и усиление SSH.
- `infra/scripts/configure_ufw.sh` — базовые правила UFW (22/80/443).
- `infra/scripts/system_updates.sh` — обновление системы.

Пример запуска:

```bash
sudo bash infra/scripts/create_user.sh deploy /tmp/id_ed25519.pub
sudo bash infra/scripts/ssh_hardening.sh
sudo bash infra/scripts/configure_ufw.sh
sudo bash infra/scripts/system_updates.sh
```

## 3) Сборка и публикация MkDocs

На сервере (или в CI) соберите статику:

```bash
pip3 install mkdocs-material
mkdocs build
```

Скопируйте содержимое `site/` в `/var/www/studlektorium/site`:

```bash
sudo mkdir -p /var/www/studlektorium/site
sudo rsync -av --delete site/ /var/www/studlektorium/site/
```

## 4) Подключение домена

У регистратора домена добавьте DNS-записи:

- `A` запись: `@` -> `PUBLIC_SERVER_IP`
- `A` запись: `www` -> `PUBLIC_SERVER_IP`

Проверьте, что DNS уже указывает на сервер:

```bash
dig +short example.com
```

## 5) Конфиг Nginx

1. Откройте `infra/nginx/studlektorium.conf` и замените `example.com` на ваш домен.
2. Скопируйте файл в Nginx:

```bash
sudo cp infra/nginx/studlektorium.conf /etc/nginx/sites-available/studlektorium.conf
sudo ln -sf /etc/nginx/sites-available/studlektorium.conf /etc/nginx/sites-enabled/studlektorium.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

## 6) Выпуск и автообновление сертификата

```bash
sudo bash infra/scripts/certbot_setup.sh example.com admin@example.com
```

Скрипт:

- устанавливает `certbot` и плагин `python3-certbot-nginx`;
- выпускает сертификат для `example.com` и `www.example.com`;
- включает `certbot.timer` (если есть) и добавляет cron-задачу;
- выполняет `certbot renew --dry-run`.

## 7) Проверка HTTPS/TLS

Проверки после деплоя:

```bash
curl -I http://example.com
curl -I https://example.com
sudo certbot certificates
systemctl status certbot.timer --no-pager
```

Ожидается:

- HTTP отвечает `301` на HTTPS.
- HTTPS отвечает `200`.
- Сертификат присутствует в списке `certbot certificates`.
- Таймер `certbot.timer` активен (или cron-задача `/etc/cron.d/certbot-renew-check`).
