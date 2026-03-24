## Итоговый проект по курсу «DevOps практики и инструменты»

## Внедрение автоматизированного процесса развертывания инфраструктуры и микросервисов в Yandex Cloud с использованием Terraform, Kubernetes, CI/CD практик и инструментов мониторинга

**Цель проекта:**
Разработать и внедрить автоматизированный процесс развертывания облачной инфраструктуры и микросервисных приложений в Yandex Cloud с использованием инструментов инфраструктуры как кода (Terraform), системы оркестрации (Kubernetes), практик непрерывной интеграции и доставки (CI/CD), а также систем мониторинга для обеспечения надёжности, масштабируемости и быстрой обратной связи.

## Схема проекта

![Схема проекта](/images/project_map.png)

### Исходные данные

Проект включает следующие компоненты:

* **[UI](https://github.com/express42/search_engine_ui)** — веб-интерфейс приложения.
* **[Crawler](https://github.com/express42/search_engine_crawler)** — сбор данных.
* **[MongoDB](https://www.mongodb.com/)** — база данных.
* **[RabbitMQ](https://www.rabbitmq.com/)** — брокер сообщений.

Все приложения разворачиваются в **кластере Kubernetes**.  
Инфраструктура полностью разворачивается в **Yandex Cloud**.

### Используемые инструменты

1. **Инфраструктура**: [Terraform](https://www.terraform.io/)  
2. **Конфигурирование инфраструктуры**: [Ansible](https://www.ansible.com/)  
3. **CI/CD**: [GitLab](https://about.gitlab.com/)  
4. **Сбор обратной связи и мониторинг**:
    - **Метрики**: [Prometheus](https://prometheus.io/)  
    - **Логирование**: [Grafana Loki](https://grafana.com/oss/loki/) + [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/)  
    - **Визуализация**: [Grafana](https://grafana.com/)  
    - **Алертинг**: [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/)  
    - **ChatOps**: [GitLab](https://about.gitlab.com/) + [Telegram](https://telegram.org/)

### Общая архитектура проекта

#### 1. Инфраструктура в Yandex Cloud

* **Network Load Balancer** — публикация сервисов Kubernetes через ingress controller.  
* **Bastion (JumpHost)** — доступ к виртуальным машинам без "белого" IP.  
* **NAT-VM** — выход ВМ в Интернет.  
* **Harbor (Container Registry)** — реестр Docker-образов с встроенным сканером уязвимостей Trivy.  
* **Kubernetes Cluster** — 1 master node + 2 worker nodes.  
* **GitLab CE** — сервер для CI/CD.  
* **GitLab Runner** — развернут в Kubernetes-кластере.  

#### 2. Развёрнутые приложения и сервисы

* **Crawler** с веб-интерфейсом, MongoDB и RabbitMQ.  
* **GitLab** для CI/CD.  
* **Система обратной связи**: Prometheus, Grafana, Loki, Promtail.  

#### 3. Настроенный процесс CI/CD

* Dockerfiles для сборки Crawler и UI в **Harbor Container Registry**.  
* GitLab проекты с репозиториями компонентов приложения.  
* CI/CD процесс включает:
    1. Автоматическая сборка Docker-образов при коммитах в ветку **master**.  
    2. Развёртывание образов в Kubernetes через Helm-чарты.  
    3. Проверка доступности UI интерфейса.  
    4. Возможность ручного удаления развернутого приложения после успешного выполнения предыдущих шагов.  

#### 4. Настроенный процесс сбора обратной связи

* Сбор метрик с помощью **Prometheus**.  
* Сбор логов через **Loki + Promtail**.  
* Визуализация метрик и логов с помощью **Grafana**.  
* Настроен алертинг с отправкой уведомлений в группу **Telegram**.  

## Запуск проекта

### Используемые локальные инструменты

Рабочая станция (Ubuntu 24.04.1 LTS ) c установленными:

* Yandex Cloud CLI 0.148.0
* Terraform v1.13.0
* Ansible core 2.16.3
* VS Code 1.100.2
* Git 2.43.0

### Подготовка рабочей машины 

1. **SSH-ключ**:
- Сгенерирован SSH-ключ без пароля (`ssh-keygen -t ed25519 -f ~/.ssh/terraform_key -N ""`), публичный ключ доступен по пути `~/.ssh/terraform_key.pub`, приватный — `~/.ssh/terraform_key`.

2. **Yandex Cloud CLI**:
- Установлен и настроен (`yc init` выполнен с OAuth-токеном)
- Инструкция по установке: [https://cloud.yandex.ru/docs/cli/quickstart](https://cloud.yandex.ru/docs/cli/quickstart)
- yc CLI нужен, чтобы мы могли автоматически получать yc_token (IAM токен с ограниченным сроком жизни), yc_cloud_id и yc_folder_id в ходе работы с terraform

3. **Terraform**:
- Установлен (версия >= 1.13).
- Инструкция по установке: [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- Настроен провайдер на зеркало Яндекса https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider.
```bash
nano ~/.terraformrc

 provider_installation {
   network_mirror {
     url = "https://terraform-mirror.yandexcloud.net/"
     include = ["registry.terraform.io/*/*"]
   }
   direct {
     exclude = ["registry.terraform.io/*/*"]
   }
 }
```
### Подготовка для запуска инфраструктуры проекта

#### 1. Склонируем или создаем проект с нашими файлами.
```bash
git clone https://github.com/dev-itsec/otus-devops.git
cd otus-devops
```
#### 2. **Настройка Yandex Cloud CLI под использование сервисного аккаунта через его авторизованный ключ**:
- Чтобы управлять инфраструктурой Yandex Cloud с помощью Terraform, будет использоваться yc CLI c отдельным профилем, настроенным под сервисный аккаунт и его авторизованный ключ (RSA пара) . Terraform через yc CLI будет получать временные IAM токены для сервисного аккаунта и подключаться в Yandex Cloud. Это позволит гибко настраивать права доступа к ресурсам.
Использование Terraform от имени аккаунта на Яндексе является менее безопасным. Время жизни IAM-токена — не больше 12 часов, а время жизни OAuth-токена — 1 год.
- Запускаем скрипт `setup_yc_to_sa.sh`, он создаст в облаке сервисный аккаунт `terraform-sa`, добавит ему роли `editor` , `storage.admin` и сгенерирует авторизованный ключ `terraform-sa-key.json` для нового профиля yc cli.
```bash
cd ycli
./setup_yc_to_sa.sh
```
   - Проверка настроек профиля
```bash
yc config list
yc config profile list
yc iam service-account list
```
#### 3. **Инициализации Terraform c возможностью хранить состояния в S3 Yandex Cloud**:
- Переходим в папку terraform и запускаем скрипт `setup_s3_to_terraform.sh`, он создаст в облаке S3 бакет `tf-state-asterisker` и сгененирует ключи доступа (не путать с авторизованным ключом) к нему для сервисного аккаунта `terraform-sa` в файл `backend-config.hcl`.
```bash
cd terraform
./setup_s3_to_terraform.sh
```
- Проверить, что файл `backend-config.hcl` создался и не пустой.
- Инициализируем проект и подключаем S3-Backend
```bash
terraform init -backend-config=backend-config.hcl
```
### 4. **Запуск инфраструктуры с использованием terraform**
- Разворачиваем всю инфрастуру описанную в [схеме проекта](/images/project_map.png) скриптом `run_terraform.sh`
- Важно всегда использовать этот скрипт при работе с terraform, тогда не придется указывать yc_token, yc_cloud_id и yc_folder_id в конфигах terraform, это все автоматически делает скрипт через переменные окружения `TF_VAR_`, используя ранее настроенный профиль для yc CLI.
```bash
./run_terraform.sh plan
./run_terraform.sh apply
```
- Если нужно запускать terraform через GitLab, то он может работать с Yandex Cloud без временных IAM токенов и установленного yc CLI, а сразу использовать авторизованный ключ сервисного аккаунта, полученный выше для настройки профиля yc CLI, указав его в `providers.tf` через `service_account_key_file = file("terraform-sa-key.json")` 

- После успешного развертывания terraform покажет все IP адреса серверов 
```bash
Outputs:

bastion_instance_external_ip = "51.250.105.91"
bastion_instance_internal_ip = "192.168.100.36"
gitlab_instance_external_ip = "51.250.23.9"
gitlab_instance_internal_ip = "192.168.100.12"
harbor_instance_external_ip = "51.250.22.152"
harbor_instance_internal_ip = "192.168.100.15"
k8s_ingress_internal_ips = [
  "10.10.10.29",
]
k8s_ingress_lb_ip = tolist([
  "84.201.171.180",
])
k8s_master_internal_ips = [
  "10.10.10.11",
]
k8s_node_internal_ips = [
  "10.10.10.16",
]
nat_instance_external_ip = "84.201.163.213"
nat_instance_internal_ip = "192.168.100.23"
```
- Сгенерирует файл `../ansible/hosts` для Ansible с серверами под Kubernetes Cluster
```bash
[master]
k8s-master-1 ansible_host=10.10.10.26

[ingress]
k8s-ingress-1 ansible_host=10.10.10.5

[node]
k8s-node-1 ansible_host=10.10.10.13
```
- Также создаст конфигурацию `~/.ssh/config.d/k8s_config` для SSH подключений через Bastion хост на сервера Kubernetes Cluster, которые находят в изолированной сети и без публичных IP адресов.
```bash
Host bastion
    HostName 51.250.105.249

Host nat-vm
    ProxyJump bastion

Host gitlab
    ProxyJump bastion

Host harbor
    ProxyJump bastion

Host k8s-master-*
    ProxyJump bastion

Host k8s-ingress-*
    ProxyJump bastion

Host k8s-node-*
    ProxyJump bastion

Host *
    User ubuntu
    ForwardAgent yes
    ControlMaster auto
    ControlPersist 5
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile ~/.ssh/terraform_key
```
- Теперь к удаленным серверам можно подключаться командами, например `ssh k8s-master-1`
### 5. **Разворачиваем и настраиваем Kubernetes Cluster с использованием kubeadm/Ansible**
- Переходим в папку ansible и запускаем скрипт `start_deploy_k8s.sh`. Скрипт развернет полностью рабочий Kubernetes Cluster.
- Для публикации сервисов в Интернет из кластера, установится Ingress Controller на ноду `k8s-ingress-1`.
```bash
cd ../ansible/k8s
./start_deploy_k8s.sh
```
 ### 6. **Настраиваем системы мониторинга и логирования Kubernetes Cluster**
 - Устаналиваем систему мониторинга и логирования на основе инструментов: Prometheus, Grafana, Loki, Promtail.
 Заполняем переменные в `vars.yml`от Ansible и запускаем скрипт `install_monitoring_k8s.sh` 
```bash
./install_monitoring_k8s.sh
```
### 7. **Настраиваем Harbor (Container Registry)**
- Устанавливаем [Harbor](https://github.com/ron7/harbor_installer)
```bash
hostnamectl set-hostname harbor.asterisker.com

git clone https://github.com/ron7/harbor_installer.git
cd harbor_installer/
chmod +x harbor.sh 
./harbor.sh 
FQDN (2)
```
- Прописываем IP адрес нашего сервера Harbor в DNS хостинге нашего домена и через 15 мин проверяем доступность по доменному имени `https://harbor.asterisker.com`
- Создаем проект и даем права учетной записи на проект 
### 8. **Настраиваем GitLab для CI/CD**
- Сначала нужно залогиниться в GitLab: http://gitlab_server_public_ip с временным паролем, который можно получить SSH командой
```bash
ssh gitlab 'sudo cat /etc/gitlab/initial_root_password'
```
- Прописываем IP адрес нашего сервера GitLab в DNS хостинге нашего домена и через 15 мин проверяем доступность по доменному имени `https://gitlab.asterisker.com`
- Cоздать группу work и репозиторий search_engine без инициализации REAME.md
- Добавить две переменные в группу work для доступа в Harbor (Settings - CI/CD - Variables): DOCKER_REGISTRY_USER, DOCKER_REGISTRY_PASSWORD
- Создать GitLab Runner в разделе Settings - CI/CD - Runners. Запомнить URL\токен и добавить их в файл с переменными `vars.yml` от Ansible.
- Устанавливаем Gitlan Runner (Kubernetes Executor) для GitLab Ci\CD скриптом `install_gitlabrunner_k8s.sh`
```bash
./install_gitlabrunner_k8s.sh
```
- Теперь необходимо запушить в ветку `master` репозитория search_engine наш проект, поэтому в корне нашего проекта выполняем
```bash
git init
git add .
git commit -m "Initial Commit"
git remote add origin git remote add origin http://gitlab.asterisker.com/work/search_engine.git
git push --set-upstream origin master
```
- После пуша, сервер GitLab запустит автоматическую сборку нашего проекта, запушит их в Harbor (реестр для хранения Docker образов), а потом опубликует его из Harbor в Kubernetes Cluster.
### 9. **Проверка доступности сервисов**
- Прописываем IP адрес балансировщика Yandex Cloud в DNS хостинге нашего домена и через 15 мин проверяем доступность сервисов опубликованных в нашем Kubernetes Cluster.
- Dashboard Kubernetes Cluster
```bash
https://dash.k8s.asterisker.com
```
- Grafana
```bash
https://grafana.asterisker.com
```
- Prometheus
```bash
https://prom.asterisker.com
```
- RabbitMQ
```bash
https://rmq.asterisker.com
```
- UI CRAWLER
```bash
https://ui.asterisker.com
```
## 10. **Удаление всей развернутой инфраструктуры**
```bash
./run_terraform.sh destroy
```
## Скрины 
- Yandex Cloud VMs
![project_schema](/images/yandexcloud.png)
- Yandex Cloud SA
![project_schema](/images/yandexcloud2.png)
- Network Load Balancer
![project_schema](/images/nlb.png)
- Dashboard Kubernetes Cluster
![project_schema](/images/dashboard_k8s.png)
![project_schema](/images/dashboard2_k8s.png)
- Terminal K9s
![project_schema](/images/terminal_k9s.png)
- GitLab CI/CD
![project_schema](/images/gitlab.png)
- Harbor
![project_schema](/images/harbor.png)
![project_schema](/images/harbor2.png)
- UI Crawler
![project_schema](/images/ui.png)
- RabbitMQ
![project_schema](/images/rabbitmq.png)
- Grafana Prometheus
![project_schema](/images/grafana1.png)
![project_schema](/images/grafana2.png)
![project_schema](/images/grafana3.png)
Grafana Loki
![project_schema](/images/grafana4.png)
Grafana Alertmanager
![project_schema](/images/grafana5.png)