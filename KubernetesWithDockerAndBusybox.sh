#!/bin/sh
set -xe

cat welcome.txt && sleep 1
read PressEnterToContinue

echo >/dev/null \
  "Lets check that docker is installed, this is our only dependency to run this demo!" 
read PressEnterToContinue
which docker
read PressEnterToContinue

echo >/dev/null \
  "Lets install k3d, a minimal kubernetes distro by rancher" 
read PressEnterToContinue
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
read PressEnterToContinue

echo >/dev/null \
  "And create our cluster" 
read PressEnterToContinue
k3d registry create myregistry.localhost --port 12345
k3d cluster create mycluster -p "8081:80@loadbalancer" --registry-use k3d-myregistry.localhost:12345

read PressEnterToContinue

echo >/dev/null \
  "And check it is up" 
read PressEnterToContinue
kubectl get nodes
read PressEnterToContinue

echo >/dev/null \
  "Let's deploy nginx as a test" 
read PressEnterToContinue
kubectl create deployment nginx --image=nginx
kubectl wait --for=condition=available deployment.apps/nginx --timeout 30s
read PressEnterToContinue

echo >/dev/null \
  "Let's create a service to expose it" 
read PressEnterToContinue
kubectl create service clusterip nginx --tcp=80:80
read PressEnterToContinue

echo >/dev/null \
  "Now create the ingress" 
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

echo >/dev/null \
  "Lets call it every 5 seconds until nginx is accessible" 
read PressEnterToContinue
while ! curl -sf localhost:8081 > /dev/null; do sleep 5; done
curl localhost:8081
read PressEnterToContinue

echo >/dev/null \
  "And push the nginx image to our registry to test it" 
docker pull nginx:latest
docker tag nginx:latest k3d-registry.localhost:12345/nginx:latest
docker push k3d-registry.localhost:12345/nginx:latest
read PressEnterToContinue

echo >/dev/null \
  "and even create a pod from it to be super sure" 
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test-registry
  labels:
    app: nginx-test-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-test-registry
  template:
    metadata:
      labels:
        app: nginx-test-registry
    spec:
      containers:
      - name: nginx-test-registry
        image: k3d-myregistry.localhost:12345/nginx:latest 
        ports:
        - containerPort: 80
EOF

kubectl wait --for=condition=available deployment.apps/nginx-test-registry --timeout 30s
kubectl get deployments
read PressEnterToContinue

echo >/dev/null \
  "Nice, everything is working so far. In case we want to debug something, we can create an interactive pod with:" 
echo>/dev/null \
  "kubectl run -i --tty debug --image=alpine --restart=Never -- sh"
echo >/dev/null \
  "Busybox or alpine can be interchanged depending if you need a pkg manager" 
read PressEnterToContinue
echo>/dev/null \
  "kubectl get events is also a good place to start if something is broken"
read PressEnterToContinue

echo>/dev/null \
  "Lets build our simple API"
(cd simple-api && docker build -t simple-api .)
read PressEnterToContinue

echo>/dev/null \
  "Test it locally"
docker run -p 8080:8080 --name some-simple-api -d simple-api
sh simple-api/test.sh && echo>/dev/null "it worked!"
docker rm -f some-simple-api

read PressEnterToContinue

echo >/dev/null \
  "time to push it to our local registry"
docker tag simple-api:latest k3d-registry.localhost:12345/simple-api:latest
docker push k3d-registry.localhost:12345/simple-api:latest
read PressEnterToContinue

echo >/dev/null \
  "and even create a deployment from it to be super sure" 
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-api
  labels:
    app: simple-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: simple-api
  template:
    metadata:
      labels:
        app: simple-api
    spec:
      containers:
      - name: simple-api
        image: k3d-myregistry.localhost:12345/simple-api:latest 
        ports:
        - containerPort: 8080
EOF

kubectl wait --for=condition=available deployment.apps/simple-api --timeout 30s
kubectl get deployments
read PressEnterToContinue

