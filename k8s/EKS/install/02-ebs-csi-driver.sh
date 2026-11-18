#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]]; then
    echo "Usage '$0 <cluster_name>'"
    echo Aborting... && exit 1
fi

##############
# Constants
##############

# Installing EBS CLI driver using Pod Identity: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md#eks-only-eks-pod-identity
SERVICE_ACC="ebs-csi-controller-sa" # driver expects this name

DIR=$(dirname "$0")

CLUSTER_NAME="$1"
CLUSTER_REGION="ap-south-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

TRUST_RELATIONSHIP_FILE="${DIR}/pod-identity-trust-relationship.json"
[[ ! -f $TRUST_RELATIONSHIP_FILE ]] && echo "Trust Relationship file for ALB Role ($TRUST_RELATIONSHIP_FILE) doesn't exist, aborting..." && exit

##############
# Functions
##############

# usage: print_with_seperator <msg>
function print_with_seperator {
    msg="$*"
    msg_len=${#msg}
    local SEPERATOR=$(python3 -c "print('-' * ($msg_len + 5))")

    printf "%s\n" "$SEPERATOR"
    printf "%s...\n" "$msg"
    printf "%s\n" "$SEPERATOR"
    echo
}

# usage: role_exists <role_name>
function role_exists {
    aws iam get-role --role-name "$1" > /dev/null 2>&1
}

# usage: eks_addon_exists <addon_name>
function eks_addon_exists {
    local ADDON_NAME="$1"
    aws eks describe-addon --cluster-name "$CLUSTER_NAME" --addon-name "$ADDON_NAME" &>/dev/null
}

##############
# Driver Code
##############

# update kubeconfig
print_with_seperator Updaing kubeconfig
aws eks update-kubeconfig --region "$CLUSTER_REGION" --name "$CLUSTER_NAME"

# Enable Pod Identity Agent
if ! eks_addon_exists "eks-pod-identity-agent"; then
    print_with_seperator Installing EKS Pod Identity Agent
    aws eks create-addon --cluster-name $CLUSTER_NAME --addon-name eks-pod-identity-agent
else
    print_with_seperator Pod Identity Agent exists, Skipping Installation
fi

# Role for CSI Driver Pod
print_with_seperator Creating Role for EBS CSI Driver
ROLE_NAME="ebs-csi-driver-cluster-scoped" # name it anything
if ! role_exists "$ROLE_NAME"; then
  aws iam create-role --role-name $ROLE_NAME \
    --assume-role-policy-document file://"${TRUST_RELATIONSHIP_FILE}"
  aws iam attach-role-policy --role-name $ROLE_NAME \
    --policy-arn arn:aws:iam::aws:policy/AmazonEBSCSIDriverEKSClusterScopedPolicy
fi

# Associate Role with Pod Identity
print_with_seperator Associating Role with Pod Identity
aws eks create-pod-identity-association --cluster-name $CLUSTER_NAME --namespace kube-system \
  --service-account $SERVICE_ACC \
  --role-arn arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}

# Install Driver
print_with_seperator Installing AWS ELB CSI Driver
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system \
  --set controller.k8sTagClusterId=$CLUSTER_NAME