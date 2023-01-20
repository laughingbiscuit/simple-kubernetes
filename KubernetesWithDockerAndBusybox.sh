#!/bin/sh
set -xe

cat welcome.txt

echo \
  "Lets check that docker is installed, this is our only dependency to run this demo!" > /dev/null
read PressEnterToContinue
docker version
read PressEnterToContinue

echo \
  "Lets install k3d, a minimal kubernetes distro by rancher" > /dev/null
read PressEnterToContinue
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
read PressEnterToContinue

echo \
  "And create our cluster" > /dev/null
read PressEnterToContinue
k3d cluster create mycluster --k3s-arg "--disable=traefik,servicelb,metrics-server,local-storage,coredns@server:*"
read PressEnterToContinue

echo \
  "And check it is up" > /dev/null
read PressEnterToContinue
kubectl get nodes
read PressEnterToContinue

