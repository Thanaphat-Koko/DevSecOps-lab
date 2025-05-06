#!/bin/bash
set -e

sudo apt update && sudo apt install -y haproxy

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
frontend kubernetes
    bind *:6443
    default_backend kubernetes-masters

backend kubernetes-masters
    balance roundrobin
    server master1 172.26.5.81:6443 check
    server master2 172.26.5.82:6443 check
    server master3 172.26.5.83:6443 check
EOF

sudo systemctl restart haproxy
