#!/bin/bash

set -e

kubectl create secret generic pgadmin-secret \
  --from-literal=PGADMIN_DEFAULT_EMAIL=admin@local.dev \
  --from-literal=PGADMIN_DEFAULT_PASSWORD=admin123

kubectl apply -f pgadmin-deploy.yaml
