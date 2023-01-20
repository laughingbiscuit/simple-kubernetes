#!/bin/sh
set -xe

cat welcome.txt && sleep 1
read PressEnterToContinue

echo \
  "Lets check that docker is installed, this is our only dependency to run this demo!" > /dev/null
read PressEnterToContinue
which docker
read PressEnterToContinue

echo \
  "Lets install k3d, a minimal kubernetes distro by rancher" > /dev/null
read PressEnterToContinue
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
read PressEnterToContinue

echo \
  "And create our cluster" > /dev/null
read PressEnterToContinue
k3d cluster create mycluster
read PressEnterToContinue

echo \
  "And check it is up" > /dev/null
read PressEnterToContinue
kubectl get nodes
read PressEnterToContinue

