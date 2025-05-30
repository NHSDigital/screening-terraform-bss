#!/usr/bin/env bash

set -e

ENV=${1?You must pass in the env you are deploying to i.e dev-mgmt, test-mgmt, live-mgmt}
AWS_REGION=${2:-'eu-west-2'}

# set kubeconfig: copy config file from EKS
# it is important to ensure that the FILE variable is unique per environment otherwise the config will get merged with the same environment file 
# when running this script for different environments in the same Jenkins workspace
if [[ ${ENV} == 'live-mgmt' ]]; then
  # live-mgmt
  CLUSTER_NAME="live-mgmt-leks-cluster"
  FILE="live-mgmt-leks-cluster_kubeconfig"
elif [[ ${ENV} == 'live-lk8s-nonprod' || ${ENV} == 'live-nonprod' ]]; then
  # live-nonprod
  CLUSTER_NAME="live-leks-cluster"
  FILE="live-leks-cluster_kubeconfig_nonprod"
elif [[ ${ENV} == 'live-lk8s-prod' || ${ENV} == 'live-prod' ]]; then
  # live-prod
  CLUSTER_NAME="live-leks-cluster"
  FILE="live-leks-cluster_kubeconfig_prod"
elif [[ ${ENV} == 'test-mgmt' ]]; then
  # test-mgmt
  CLUSTER_NAME="test-mgmt-leks-cluster"
  FILE="test-mgmt-leks-cluster_kubeconfig"
elif [[ ${ENV} == 'test-lk8s' || ${ENV} == 'test-k8s' ]]; then
  # test-k8s
  CLUSTER_NAME="test-leks-cluster"
  FILE="test-leks-cluster_kubeconfig"
elif [[ ${ENV} == 'dev-mgmt' ]]; then
  # dev-mgmt
  CLUSTER_NAME="dev-mgmt-leks-cluster"
  FILE="dev-mgmt-leks-cluster_kubeconfig"
elif [[ ${ENV} == 'dev-lk8s' ||  ${ENV} == 'dev-k8s' ]]; then
  # dev-k8s
  CLUSTER_NAME="dev-leks-cluster"
  FILE="dev-leks-cluster_kubeconfig"
else
  echo "Invalid env name ${ENV}"
  exit 1
fi

# The below if else block of code is to handle the case where the test cluster doesn't yet exist when using the CRUD pipeline.

if [[ ${ENV} == 'test-mgmt' || ${ENV} == 'test-lk8s' || ${ENV} == 'test-k8s' ]]; then
  aws eks update-kubeconfig --kubeconfig ${WORKSPACE}/${FILE}  --region=${AWS_REGION} --name=${CLUSTER_NAME} 2>&1 >/dev/null || true
else
  aws eks update-kubeconfig --kubeconfig ${WORKSPACE}/${FILE}  --region=${AWS_REGION} --name=${CLUSTER_NAME} 2>&1 >/dev/null
fi

echo "${WORKSPACE}/${FILE}"
