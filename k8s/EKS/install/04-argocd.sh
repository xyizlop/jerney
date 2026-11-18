#!/usr/bin/env bash
set -e

if [[ $# -ne 1 ]]; then
    echo "Usage '$0 <cluster_name>'"
    echo Aborting... && exit 1
fi

CLUSTER_NAME="$1"
CLUSTER_REGION="ap-south-1"

# set kubeconfig current context
echo "Updating kubconfig..."
aws eks update-kubeconfig --region "$CLUSTER_REGION" --name "$CLUSTER_NAME"

echo "Installing ArgoCD in 'argocd' namespace using HELM charts..."
# namespace
kubectl create namespace argocd

# clone repo
# good to clone at /tmp because it's not part of your project
cd /tmp
git clone https://github.com/argoproj/argo-helm.git
cd argo-helm/charts/argo-cd
helm dependency up # downloads dependencies from Chart.yaml

# install
helm install argocd . --values values.yaml --wait --timeout 10m -n argocd

# patching because for aws alb type 'instance' -> NodePort is needed
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'