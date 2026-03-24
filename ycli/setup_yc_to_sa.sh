#!/bin/bash

# Проверка наличия yc CLI
if ! command -v yc &> /dev/null; then
    echo "Yandex Cloud CLI (yc) не установлен. Установите его: https://cloud.yandex.ru/docs/cli/quickstart"
    exit 1
fi

# Получение Cloud ID
CLOUD_ID=$(yc config get cloud-id)
if [ -z "$CLOUD_ID" ]; then
    echo "Не удалось получить Cloud ID. Проверьте конфигурацию yc CLI (yc init)."
    exit 1
fi

# Получение Folder ID
FOLDER_ID=$(yc config get folder-id)
if [ -z "$FOLDER_ID" ]; then
    echo "Не удалось получить Folder ID. Проверьте конфигурацию yc CLI (yc init)."
    exit 1
fi

# Создание сервисного аккаунта
# Задаем имя для нового сервисного аккаунта
SA_NAME="terraform-sa"

echo "Создание сервисного аккаунта $SA_NAME"
yc iam service-account create --name "$SA_NAME" --folder-id $FOLDER_ID --description "Service account for Terraform"

# Получаем ID от созданного сервисного аккаунта
SA_ID=$(yc iam service-account get "$SA_NAME" --format json | jq -r '.id')
if [ -z "$SA_ID" ]; then
    echo "Сервисный аккаунт $SA_NAME не создан"
    exit 1
fi
    echo "Сервисный аккаунт $SA_NAME создан с ID: $SA_ID"

# Назначение ролей editor и storage.admin (S3) сервисному аккаунту
echo "Назначение ролей сервисному аккаунту..."
yc resource-manager folder add-access-binding "$FOLDER_ID" \
    --role editor \
    --subject serviceAccount:"$SA_ID"
yc resource-manager folder add-access-binding "$FOLDER_ID" \
    --role storage.admin \
    --subject serviceAccount:"$SA_ID"

# Создание авторизованного ключа для сервисного аккаунта (RSA пара)
echo "Создание авторизованного ключа для сервисного аккаунта..."
yc iam key create --service-account-id "$SA_ID" --output terraform-sa-key.json
if [ $? -ne 0 ]; then
    echo "Ошибка создания ключа для $SA_NAME"
    exit 1
fi

# Настройка профиля yc CLI для выполнения операций от имени сервисного аккаунта
yc config profile create "$SA_NAME"
yc config set service-account-key terraform-sa-key.json
yc config set cloud-id "$CLOUD_ID"
yc config set folder-id "$FOLDER_ID"
yc config profile list
yc config list

# Если вдруг будут проблемы с новым профилем yc CLI, то можно переключиться обратно на профиль по умолчанию
# yc config profile list
# yc config profile activate default
# yc config profile delete terraform-sa



