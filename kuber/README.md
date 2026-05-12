# Развёртывание Telegram-бота с PostgreSQL в Kubernetes

## Структура проекта

- **cheardantsev-bot** - Docker-образ с Telegram-ботом.
- **cheardantsev-db** - Docker-образ с PostgreSQL базой данных.
- **Kubernetes манифесты** для развёртывания бота и базы данных.

## Шаги по развёртыванию

### 1. Подготовка Docker-образов

1. **Создание Docker-образа для PostgreSQL базы данных**:

    ```bash
    docker build -t cr.yandex/crpo3n46hh2cgjb7986e/cheardantsev-db:latest .
    ```

    ```bash
    docker push cr.yandex/crpo3n46hh2cgjb7986e/cheardantsev-db:latest
    ```

2. **Создание Docker-образа для Telegram-бота**:

    ```bash
    docker build -t cr.yandex/crpo3n46hh2cgjb7986e/cheardantsev-bot:latest .
    ```

    ```bash
    docker push cr.yandex/crpo3n46hh2cgjb7986e/cheardantsev-bot:latest
    ```

### 2. Создание пространства имён

    ```bash
    kubectl create namespace cheardantsev-ns
    ```

### 3. Развёртывание PostgreSQL базы данных

    ```bash
    kubectl apply -f database.yaml
    ```

### 4. Развёртывание Telegram-бота

    ```bash
    kubectl apply -f tripplanner.yaml
    ```

### 5. Проверка состояния

    ```bash
    kubectl get pods -n cheardantsev-ns
    ```

    ```bash
    kubectl logs -l app=cheardantsev-bot -n cheardantsev-ns --tail=100
    ```

### 5. Удаление всех ресурсов

```bash
kubectl delete -f tripplanner.yaml
kubectl delete -f database.yaml
