#!/bin/bash
set -e

# 1. Apply Calico CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

# 2. รอ Calico pod ขึ้นครบ
echo "⏳ กำลังรอ Calico Pod ขึ้น..."
kubectl rollout status daemonset/calico-node -n kube-system

echo "✅ Calico ติดตั้งเสร็จเรียบร้อย!"
