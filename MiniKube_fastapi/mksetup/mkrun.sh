#!/bin/bash

# Run the script using non-root user: sh mkrun.sh
echo "Starting minikube cluster"
whoami

echo "Starting minikube"
minikube start --driver=podman --container-runtime=docker --insecure-registry
echo "Checking kubectl existance"
kubectl --version
if [ "$?" != "0" ]; then
	echo "kubectl not found... installing now"
	minikube kubectl -- get po -A
	alias kubectl="minikube kubectl --"
fi
#Enable docker registry
minikube addons enable registry
#Enable Ingress
minikube addons enable ingress
#Create minikube GUI Dashboard
minikube addons enable dashboard
#setting up the enviorment
minikube docker-env
eval $(minikube -p minikube docker-env)

#Building docker image
cd /opt/MiniKube_fastapi/mksetup
docker build -t myfastapi .
