#!/bin/bash
set -e

sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service

# 1. Update ระบบ
sudo dnf update -y

# 2. ติดตั้ง dependency
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2 curl

# 3. เพิ่ม Docker repo
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 4. ติดตั้ง containerd.io
sudo dnf install -y containerd.io

# 5. สร้าง config containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 6. ปรับ config: ใช้ Systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# 7. Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# 8. ปิด swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo free -h
grep swap /etc/fstab > swap-log.txt

# 9. เปิด kernel module จำเป็น
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set permanent
sh -c 'echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf'

# 10. ตั้งค่า sysctl สำหรับ Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

/sbin/sysctl -p /etc/sysctl.d/k8s.conf

sudo sysctl --system

# Tuning. Mor infomation see tuning.
cat <<EOF | sudo tee /etc/sysctl.d/90-sys-tuning.conf > /dev/null
# Additional sysctl flags that kubelet expects
kernel.panic = 10
kernel.panic_on_oops = 1
vm.overcommit_memory = 1

net.core.somaxconn = 65535
EOF

cat <<EOF | sudo tee /etc/sysctl.d/90-net-tuning.conf > /dev/null
# Tweak Network
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8096
net.netfilter.nf_conntrack_max = 1048576

EOF

sysctl --system

# 11. เพิ่ม Kubernetes repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
EOF

# 12. ติดตั้ง kubelet kubeadm kubectl
sudo dnf install -y kubelet kubeadm kubectl nfs-utils dnf-plugin-versionlock iscsi-initiator-utils

# 13. Hold เวอร์ชันไว้ (ป้องกันการอัปเดต)
sudo dnf versionlock add kubelet kubeadm kubectl

sudo systemctl enable --now iscsid

# 14. เปิดใช้งาน kubelet
sudo systemctl enable --now kubelet

# 15. ตรวจสอบเวอร์ชัน
kubeadm version
kubelet --version
kubectl version --client
containerd --version

echo "✅ เสร็จแล้ว พร้อม kubeadm init ได้เลย!"
