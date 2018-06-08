#!/bin/bash

set -ex

KUBE_HOME="${HOME}/.kube"
KUBE_CONFIG="${KUBE_HOME}/config"
KUBE_MASTER="${KUBE_MASTER:-master.cluster.k8s}"

sudo kubeadm init --apiserver-cert-extra-sans "$KUBE_MASTER" --pod-network-cidr 10.244.0.0/16

mkdir -p "$KUBE_HOME"
sudo cp /etc/kubernetes/admin.conf "$KUBE_CONFIG"
sudo chown "$USER:$USER" "$KUBE_CONFIG"

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/myhro/ansible-k8s/master/manifests/traefik.yaml
