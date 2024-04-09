#!/bin/bash

# Set variables
NAMESPACE="exercise"
REGION="us-east-1"
CLUSTERNAME="exercise-cluster"
APPLICATIONNAME="rattle"

# Export AWS credentials and configure kubeconfig
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTERNAME"
if [ $? -ne 0 ]; then
  echo "Error: Failed to update kubeconfig."
  exit 1
fi

# Check if the namespace exists
if kubectl get namespace "$NAMESPACE" &> /dev/null; then
  echo "Namespace $NAMESPACE exists"
else
  echo "Namespace $NAMESPACE does not exist. Creating..."
  kubectl create namespace "$NAMESPACE"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create namespace $NAMESPACE."
    exit 1
  fi
fi

# Set the namespace as default
kubectl config set-context --current --namespace="$NAMESPACE"
echo "Setting $NAMESPACE as the default namespace"
echo "Done!"

# Navigate to the application directory
cd "./$APPLICATIONNAME" || { echo "Error: Directory ./$APPLICATIONNAME does not exist."; exit 1; }

# Check if the Helm chart exists
if helm ls --short | grep -q "^$APPLICATIONNAME$"; then
  # Helm chart exists, perform upgrade
  echo "Helm chart $APPLICATIONNAME already exists. Performing upgrade..."
  helm upgrade -i "$APPLICATIONNAME" .
else
  # Helm chart does not exist, perform install
  echo "Helm chart $APPLICATIONNAME does not exist. Performing install..."
  helm install "$APPLICATIONNAME" .
fi
