# Notes

## 1. Create service account

```bash
gcloud iam service-accounts create kirill-amurskiy

gcloud projects add-iam-policy-binding otus-cloud-2019-09-274812 \
    --member "serviceAccount:kirill-amurskiy@otus-cloud-2019-09-274812.iamgserviceaccount.com" \
    --role "roles/owner"

gcloud iam service-accounts keys create gcloud-kirill-amurskiy-key.json \
    --iam-account kirill-amurskiy@otus-cloud-2019-09-274812.iam.gserviceaccount.com
```

