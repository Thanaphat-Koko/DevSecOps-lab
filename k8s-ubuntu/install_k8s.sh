#!/bin/bash
set -e

# 1. Update ระบบ
sudo apt update && sudo apt upgrade -y

# 2. ติดตั้ง dependency
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 3. เพิ่ม Docker repo (เพื่อดึง containerd ใหม่)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

# 4. ติดตั้ง containerd ตัวใหม่
sudo apt install -y containerd.io

# 5. สร้าง config containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 6. ปรับ config: ใช้ Systemd cgroup driver (สำคัญมากกับ Kubernetes 1.33)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# 7. Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# 8. ปิด swap (kubeadm ไม่รองรับ swap)
sudo swapoff -a
sudo free -h
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 9. เปิด module จำเป็น
sudo modprobe overlay
sudo modprobe br_netfilter

# 10. Set sysctl params สำหรับ Kubernetes networking
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# 11. เพิ่ม Kubernetes repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

# 12. ติดตั้ง kubelet kubeadm kubectl
sudo apt install -y kubelet kubeadm kubectl nfs-common

# 13. Hold เวอร์ชันไว้ ไม่ให้อัพเดทผิด
sudo apt-mark hold kubelet kubeadm kubectl

# 14. เช็คเวอร์ชัน
kubeadm version
kubelet --version
kubectl version --client
containerd --version

echo "✅ เสร็จแล้ว พร้อม kubeadm init ได้เลย!"
