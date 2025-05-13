# Ref : https://longhorn.io/docs/1.8.1/deploy/install/install-with-helm/

#!/bin/bash
set -e

helm repo add longhorn https://charts.longhorn.io

helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.8.1

kubectl -n longhorn-system get pod