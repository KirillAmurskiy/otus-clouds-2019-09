#!/bin/bash

sudo apt-get update
sudo apt-get install docker.io -y
sudo docker login -u KirillAmurskiy -p $GITHUB_ACCESSTOKEN docker.pkg.github.com
sudo mkdir -p /root/.docker
sudo cp .docker/config.json /root/.docker/config.json
sudo apt-get update
sudo apt-get install docker-compose -y