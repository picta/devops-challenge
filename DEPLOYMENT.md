# System Architecture

```text
                                     ┌──────────────────┐
                                     │ CLIENT / BROWSER │
                                     └──────────────────┘
                                               │
                                               ▼
                                      http://127.0.0.1:80
                                               │
===============================================│===============================================
                                               ▼  (Kind Port 80:30080)
                  ┌────────────────────────────────────────────────────────┐
                  │                   KUBERNETES CLUSTER(Kind)             │
                  │                                                        │
                  │   Kind Port 80:30080                                   │
                  │             │                                          │
                  │             ▼                                          │
                  │   votes-ui Port 80:4000 (Node.js)                      │
                  │             │                                          │
                  │             ▼                                          │
                  │   votes-api Service Port 5000 (Flask)                  │
                  │             │                                          │
                  │             ▼                                          │
                  │   Postgres Port 5432                                   │
                  │                                                        │
                  └────────────────────────────────────────────────────────┘

===============================================│===============================================

```
# DevOps Challenge Instructions

## Create container images (ALREADY CREATED under my docker hub)

$ docker login -u `<username>` <br>
$ cd `<app_name>` && docker build . -t `<app_name>` <br>
$ docker tag `<app_name>` `<user_name>`/`<app_name>`:latest <br>
$ docker push `<username>`/`<app_name>`:latest <br>

## 1. Initialize terraform
$ terraform init


## 2. Plan and/or apply
$ terraform apply

## 3. Confirm cluster availability
$ kind get clusters <br>
$ kubectl get pods -n voting-app

## Vote !
http:127.0.0.1:80
