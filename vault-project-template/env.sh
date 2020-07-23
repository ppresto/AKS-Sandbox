#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
vaultInstallDir="../install-vault-raft"
unset TF_VAR_namespace
export KUBECONFIG=${DIR}/${vaultInstallDir}/tmp/k8s_config
#export KUBECONFIG=/Users/patrickpresto/Projects/AKS-Sandbox/install-vault/scripts/../tmp/k8s_config
export VAULT_ADDR="http://127.0.0.1:8200"
export TF_VAR_VAULT_ADDR=${VAULT_ADDR}
export VAULT_TOKEN=$(cat ${vaultInstallDir}/tmp/cluster-keys.json| jq -r ".root_token")
export TF_VAR_VAULT_TOKEN=${VAULT_TOKEN}

# Setup kubectl port forward to access vault with localhost
if [[ ! $(ps -ef | grep "kubectl port-forward" | grep -v grep) ]]; then
    kubectl port-forward vault-0 8200:8200 > /dev/null 2>&1 &
else
    echo "kubectl port-forward running"
fi