#!/bin/bash

sudo apt update
sudo apt install docker.io -y
sudo docker login -u KirillAmurskiy -p $GITHUB_ACCESSTOKEN docker.pkg.github.com
sudo apt install docker-compose -y