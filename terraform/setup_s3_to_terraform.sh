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

# Проверка существования и создания бакета 
# Задаем имя для нового бакета
BUCKET_NAME="tf-state-asterisker"

echo "Проверка существования бакета $BUCKET_NAME"
BUCKET_CHECK=$(yc storage bucket get "$BUCKET_NAME" 2>&1)
BUCKET_STATUS=$?
if [ $BUCKET_STATUS -ne 0 ]; then
    echo "Бакет $BUCKET_NAME не найден (status: $BUCKET_STATUS). Создаю... "
    CREATE_BUCKET_OUTPUT=$(yc storage bucket create --name "$BUCKET_NAME" --folder-id "$FOLDER_ID" 2>&1)
    if [ $? -ne 0 ]; then
        echo "Ошибка создания бакета $BUCKET_NAME"
        echo "Ошибка: $CREATE_BUCKET_OUTPUT"
        exit 1
    fi
    echo "Бакет $BUCKET_NAME успешно создан"
else
    echo "Бакет $BUCKET_NAME уже существует"
fi

# Создание ключей доступа для сервисного аккаунта
SA_NAME="terraform-sa"

echo "Генерация ключа для $SA_NAME..."
KEYS=$(yc iam access-key create --service-account-name "$SA_NAME" --format json 2>&1)
if [ $? -ne 0 ]; then
    echo "Ошибка генерации ключа для $SA_NAME"
    echo "Ошибка: $KEYS"
    exit 1
fi
ACCESS_KEY=$(echo "$KEYS" | jq -r '.access_key.key_id')
SECRET_KEY=$(echo "$KEYS" | jq -r '.secret')

# Проверка создания ключей
if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo "Нет ключей для $SA_NAME"
    echo "Ошибка: $KEYS"
    exit 1
fi

# Запись ключей в backend-config.hcl
BACKEND_CONFIG="backend-config.hcl"

cat <<EOF > "$BACKEND_CONFIG"
access_key = "$ACCESS_KEY"
secret_key = "$SECRET_KEY"
EOF

# Вывод для проверки
echo "Ключи записаны в $BACKEND_CONFIG:"
echo "access_key=$ACCESS_KEY"
echo "secret_key=$SECRET_KEY"

