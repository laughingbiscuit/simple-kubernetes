#!/bin/sh
set -xe

echo "Lets check that docker is installed, this is our only dependency to run this demo!" > /dev/null
docker version
read EnterToContinue

echo "Lets install k3d, a minimal kubernetes distro by rancher" > /dev/null
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
read EnterToContinue

echo "And create our cluster" > /dev/null
k3d cluster create mycluster

echo "And check it is up" > /dev/null
kubectl get nodes
read EnterToContinue

