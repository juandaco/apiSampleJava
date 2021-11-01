#!/usr/bin/env bash

# Initialize minikube cluster
minikube start
# Verify minikube cluster 
minikube status

# Get updated version of Jenkins Helm chart
helm repo add jenkinsci https://charts.jenkins.io
helm repo update

# Create jenkins namespace
kubectl create namespace jenkins

# Create PersitentVolume for jenkins data (jenkins-pv)
kubectl apply -f jenkins-volume.yaml

# Create jenkins ServiceAccount
kubectl apply -f jenkins-sa.yaml

# Install jenkins helm charts with custom values
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f jenkins-values.yaml $chart

# Print jenkins admin password
jsonpath="{.data.jenkins-admin-password}"
secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
echo "Jenkins Admin Password: $(echo "$secret" | base64 --decode)"

# Print jenkins URL
jsonpath="{.spec.ports[0].nodePort}"
NODE_PORT=$(kubectl get -n jenkins -o jsonpath="$jsonpath" services jenkins)
jsonpath="{.items[0].status.addresses[0].address}"
NODE_IP=$(kubectl get nodes -n jenkins -o jsonpath="$jsonpath")
echo "http://$NODE_IP:$NODE_PORT/login"
