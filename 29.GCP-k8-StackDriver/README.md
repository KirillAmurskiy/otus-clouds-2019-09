# 29.GCP-k8-StackDriver

## Описание

1. Приложение - заготовка для социальной сети. Nginx маршрутизирует запросы на
бэкэнд и фронтэнд.

## Notes

### 1. Работы с GKE

1. Создать кластер

    ```bash
    # Create cluster
    gcloud container clusters create otus-cluster   --num-nodes=2
    ```

2. Далее можно работать как обычно через kebectl.

