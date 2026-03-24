#!/bin/bash

# Проверка аргумента --only-vars
ONLY_VARS=false
if [ "$1" == "--only-vars" ]; then
    ONLY_VARS=true
fi

# Проверка наличия yc CLI
if ! command -v yc &> /dev/null; then
    echo "Yandex Cloud CLI (yc) не установлен. Установите его: https://cloud.yandex.ru/docs/cli/quickstart"
    exit 1
fi

# Проверка, что передан аргумент для Terraform
if [ -z "$1" ]; then
    echo "Использование: $0 <terraform_command> [args...]"
    echo "Пример: $0 apply"
    exit 1
fi

# Получение временного IAM-токена
IAM_TOKEN=$(yc iam create-token)
if [ -z "$IAM_TOKEN" ]; then
    echo "Не удалось получить IAM-токен. Проверьте конфигурацию yc CLI (yc init) и права доступа."
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

# Установка переменных окружения для Terraform
export TF_VAR_yc_token="$IAM_TOKEN"
export TF_VAR_yc_cloud_id="$CLOUD_ID"
export TF_VAR_yc_folder_id="$FOLDER_ID"

# Вывод информации для отладки
echo "### Установлены переменные окружения: ###"
echo "TF_VAR_yc_token=$IAM_TOKEN"
echo "TF_VAR_yc_cloud_id=$TF_VAR_yc_cloud_id"
echo "TF_VAR_yc_folder_id=$TF_VAR_yc_folder_id"

# Если указан --only-vars, останавливаемся здесь
if [ "$ONLY_VARS" = true ]; then
    echo "### Only variables set, exiting as per --only-vars flag ###"
    exit 0
fi

# Запуск Terraform с переданными аргументами
terraform "$@"

# Проверка статуса выполнения
if [ $? -eq 0 ]; then
    echo "Terraform успешно выполнен с командой: $@"
else
    echo "Ошибка при выполнении Terraform с командой: $@"
    exit 1
fi