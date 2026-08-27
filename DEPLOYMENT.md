# Port Mapping Flow
Client 127.0.0.1:80 -> Kind NodePort 30080 -> Service Port 80 -> Container Port 4000 (Node.js)

# DevOps Challenge Instructions

## Create container images (ALREADY CREATED under my docker hub)

$ cd <app_name> && docker build . -t <app_name> <br>
$ docker login -u <username> <br>
$ docker tag <app_name> <user_name>/<app_name>:latest <br>
$ docker push <username>/<app_name>:latest <br>

## 1. Initialize terraform
$ terraform init


## 2. Plan and/or apply
$ terraform apply

## 3. Confirm cluster availability
$ kind get clusters <br>
$ kubectl get pods -n voting-app

## Vote !
http:127.0.0.1:80
