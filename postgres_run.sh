#!/bin/bash

set -e

echo "🔐 [1/4] สร้าง Secret สำหรับ PostgreSQL password..."
kubectl create secret generic postgres-secret --from-literal=password='mypassword' --dry-run=client -o yaml | kubectl apply -f -

echo "📝 [2/4] สร้างไฟล์ StatefulSet + Service สำหรับ PostgreSQL..."
kubectl apply -f postgres-deploy.yaml

echo "✅ PostgreSQL StatefulSet ถูก deploy แล้ว"

echo "⏳ [3/4] รอ pod postgres-0 พร้อมใช้งาน..."
kubectl wait --for=condition=Ready pod/postgres-0 --timeout=120s

echo "📁 [4/4] ตรวจสอบ PVC ที่สร้าง..."
kubectl get pvc

echo "🎉 เสร็จสิ้น! PostgreSQL ถูก deploy พร้อมใช้แล้ว (พร้อม PVC จาก Longhorn)"