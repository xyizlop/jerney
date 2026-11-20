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
PROJECT_ROOT=$(realpath "$(dirname "$0")/../../..")
HELM_DIR="${PROJECT_ROOT}/k8s/EKS/helm/jerney"
APPLICATION_NAME="jerney"
helm upgrade --install "$APPLICATION_NAME" "$HELM_DIR" --values "$HELM_DIR/values.yaml" -n jerney --create-namespace

