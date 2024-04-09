#!/bin/bash

NAMESPACE="exercise"
REGION="us-east-1"
CLUSTERNAME="exercise-cluster"
APPLICATIONNAME="rattle"

## Export AWS credentials of the user who
## took the massive responsibility to 
## deploy the EKS Cluster

## Configure Kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTERNAME

# Check if the namespace exists
if kubectl get namespace "$NAMESPACE" &> /dev/null; then
  echo "Namespace $NAMESPACE exists"
else
  echo "Namespace $NAMESPACE does not exist. Creating"
  kubectl create namespace $NAMESPACE  
fi

kubectl config set-context --current --namespace=$NAMESPACE


## Run helm create <applicationname> and make changes
## to the configuration files

# Check if the application directory exists
if [ ! -d "./$APPLICATIONNAME" ]; then
  echo "Directory ./$APPLICATIONNAME does not exist."
  exit 1
fi

# Navigate to the ./rattle directory
cd ./$APPLICATIONNAME || exit 1

# Check if the Helm chart exists
if helm list -q | grep -q "^$APPLICATIONNAME\$"; then
  # Helm chart exists, perform upgrade
  helm upgrade -i "$APPLICATIONNAME" .
else
  # Helm chart does not exist, perform install
  helm install "$APPLICATIONNAME" .
fi