#!/usr/bin/env bash

kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/C:/Users/kir/.docker/config1.json \
    --type=kubernetes.io/dockerconfigjson

kubectl apply -f easyrates-reader-service.yaml
kubectl apply -f easyrates-writer-service.yaml

kubectl apply -f easyrates-reader-deployment.yaml
kubectl apply -f easyrates-writer-deployment.yaml

kubectl apply -f easyrates-reader-hpa.yaml