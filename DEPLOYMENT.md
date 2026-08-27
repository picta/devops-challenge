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

## 0. Prerequisites
Docker version 29.7.2 (Installed using Docker desktop using default settings.)
Kind version 0.33.0 <br>
Terraform version v1.16.0

## 1. Create container images (ALREADY CREATED under my docker hub, please skip to step #2)

$ docker login -u `<username>` <br>
$ cd `<app_name>` && docker build . -t `<app_name>` <br>
$ docker tag `<app_name>` `<user_name>`/`<app_name>`:latest <br>
$ docker push `<username>`/`<app_name>`:latest <br>

## 2. Initialize terraform
$ terraform init


## 3. Plan and/or apply
$ terraform apply

## 4. Confirm cluster availability
$ kind get clusters <br>
$ kubectl get pods -n voting-app

## 5. Vote !
http:127.0.0.1:80
