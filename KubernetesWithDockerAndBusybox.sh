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
k3d cluster create mycluster -p "8081:80@loadbalancer"
read PressEnterToContinue

echo \
  "And check it is up" > /dev/null
read PressEnterToContinue
kubectl get nodes
read PressEnterToContinue

echo \
  "Let's deploy nginx as a test" > /dev/null
read PressEnterToContinue
kubectl create deployment nginx --image=nginx
kubectl wait --for=condition=available deployment.apps/nginx --timeout 30s
read PressEnterToContinue

echo \
  "Let's create a service to expose it" > /dev/null
read PressEnterToContinue
kubectl create service clusterip nginx --tcp=80:80
read PressEnterToContinue

echo \
  "Now create the ingress" > /dev/null
read PressEnterToContinue

cat << EOF | kubectl apply -f -

# apiVersion: networking.k8s.io/v1beta1 # for k3s < v1.19
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
read PressEnterToContinue

echo \
  "Lets call it every 5 seconds until nginx is accessible" > /dev/null
read PressEnterToContinue
while ! curl -sf localhost:8081 > /dev/null; do sleep 5; done
curl localhost:8081
read PressEnterToContinue
