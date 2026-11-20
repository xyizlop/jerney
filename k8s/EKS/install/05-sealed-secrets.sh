#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage '$0 <cluster_name>'"
    echo Aborting... && exit 1
fi

CLUSTER_NAME="$1"
CLUSTER_REGION="ap-south-1"
# set kubeconfig current context
echo Updating kubconfig...
aws eks update-kubeconfig --region "$CLUSTER_REGION" --name "$CLUSTER_NAME"

helm repo add sealed-secrets https://bitnami.github.io/sealed-secrets
helm repo update
helm install sealed-secrets sealed-secrets/sealed-secrets \
  -n kube-system \
  --set-string fullnameOverride=sealed-secrets-controller