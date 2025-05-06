#!/bin/bash

set -e

echo "🚀 [1/2] ติดตั้ง Longhorn CSI Driver..."
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml

echo "⏳ รอ Longhorn pods ขึ้น..."
kubectl wait --for=condition=available --timeout=180s deployment/longhorn-ui -n longhorn-system

echo "✅ Longhorn ติดตั้งแล้ว"

echo "📦 [2/2] ตั้ง Longhorn เป็น default StorageClass..."
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


