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
k3d cluster create mycluster -p "80:80@loadbalancer" --registry-use k3d-myregistry.localhost:12345

read PressEnterToContinue

echo >/dev/null \
  "And check it is up" 
read PressEnterToContinue
kubectl get nodes
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
#docker run -p 80:80 --name some-simple-api -d simple-api
#sh simple-api/test.sh && echo>/dev/null "it worked!"
#docker rm -f some-simple-api

read PressEnterToContinue

echo >/dev/null \
  "time to push it to our local registry"
docker tag simple-api:latest k3d-registry.localhost:12345/simple-api:latest
docker push k3d-registry.localhost:12345/simple-api:latest
read PressEnterToContinue

echo >/dev/null \
  "lets create a persistent volume" 
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi
EOF

echo >/dev/null \
  "and create a deployment" 
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
        - containerPort: 80
        volumeMounts:
        - name: volv
          mountPath: /data
      volumes:
      - name: volv
        persistentVolumeClaim:
          claimName: local-path-pvc
EOF


kubectl wait --for=condition=available deployment.apps/simple-api --timeout 30s
kubectl get deployments
kubectl create service clusterip simple-api --tcp=80:80
read PressEnterToContinue

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-api-ingress
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
            name: simple-api
            port:
              number: 80
EOF
read PressEnterToContinue

while ! curl -sf localhost/cgi-bin/rabbits > /dev/null; do sleep 1; done

curl -f -XPOST localhost/cgi-bin/rabbits -d '{"id":1, "name":"bugs"}'
curl -f localhost/cgi-bin/rabbits

kubectl scale deployment simple-api --replicas=0

# wait until error
while curl -sf localhost/cgi-bin/rabbits > /dev/null; do sleep 1; done

curl localhost/cgi-bin/rabbits
kubectl scale deployment simple-api --replicas=5
while ! curl -sf localhost/cgi-bin/rabbits > /dev/null; do sleep 1; done
sleep 2
kubectl get deployment simple-api
curl -sf -XPOST localhost/cgi-bin/rabbits -d '{"id":2, "name":"bunny"}'
curl -sf -XPOST localhost/cgi-bin/rabbits -d '{"id":3, "name":"diamond"}'
curl -sf -XPOST localhost/cgi-bin/rabbits -d '{"id":4, "name":"ebony"}'
curl -sf -XPOST localhost/cgi-bin/rabbits -d '{"id":5, "name":"bobby"}'
curl -sf -XPOST localhost/cgi-bin/rabbits -d '{"id":6, "name":"honey"}'
curl -sf localhost/cgi-bin/rabbits

