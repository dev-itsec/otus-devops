#!/bin/bash
echo "Проверяем доступность хостов..."
ansible all -i ../hosts -m ping
if [ $? -ne 0 ]; then
    echo "Один из хостов недоступен. Проверьте доступность хостов и корректность заполнения ansible/hosts"
    exit 1
else
    echo "Запускаем playbook..."
    ansible-playbook -i ../hosts main_playbook.yml
    if [ $? -ne 0 ]; then
        echo "Ошибка: выполнение playbook завершилось с ошибкой."
        exit 2
    else
        echo "Playbook успешно выполнен."
    fi
fi
