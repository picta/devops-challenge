# Port Mapping Flow
Client 127.0.0.1:80 -> Kind NodePort 30080 -> Service Port 80 -> Container Port 4000 (Node.js)

# DevOps Challenge Instructions

## Create container images

cd <app_name> && docker build . -t <app_name>
docker login -u <username>
docker tag <app_name> <user_name>/<app_name>:latest
docker push <username>/<app_name>:latest

## 1. Initialize terraform
$ terraform init


## 2. Plan and/or apply
$ terraform apply

## 3. Confirm cluster availability
$ kind get clusters
$ kubectl get pods -n voting-app

## Vote !
http:127.0.0.1:80
