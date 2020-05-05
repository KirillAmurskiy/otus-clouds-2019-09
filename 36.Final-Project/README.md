# Notes

## Развертывание перед защитой

1. Создать БД - `terraform apply`

2. Создать кластер k8

   ```bash
   gcloud container clusters create otus36-cluster \
   --num-nodes=1 \
   # regional cluster will creates nodes in every zones in region
   --region=europe-north1 \
   # has rights for accassing
   --service-account=otus36-service-account@otus-cloud-2019-09-274812.iam.gserviceaccount.com \
   # it's necessary for accassing to CloudSql through private ip
   --enable-ip-alias \
   --enable-autoscaling \
   --min-nodes=0 \
   --max-nodes=3

   # try to make downscaling faster
   gcloud beta container clusters update otus36-cluster \
   # gcloud beta not work without it WTF???
   --region=europe-north1 \
   --autoscaling-profile optimize-utilization
   ```

3. Прописать в reader и writer актуальный адрес Pg12.

4. Запустить приложение в кластере - `./k8-gki/deploy-all-gke.sh`
