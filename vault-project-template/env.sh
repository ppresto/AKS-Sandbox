#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
vaultInstallDir="../install-vault-raft"
if [[ -z ${TF_VAR_namespace} ]]; then 
    ns="default"
else
    ns=${TF_VAR_namespace}
fi
unset TF_VAR_namespace

export KUBECONFIG=${DIR}/${vaultInstallDir}/tmp/k8s_config
#export KUBECONFIG=/Users/patrickpresto/Projects/AKS-Sandbox/install-vault/scripts/../tmp/k8s_config
export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=$(terraform output -state=${vaultInstallDir}/terraform.tfstate vault-addr)
export TF_VAR_VAULT_ADDR=${VAULT_ADDR}
export VAULT_TOKEN=$(cat ${vaultInstallDir}/tmp/cluster-keys.json| jq -r ".root_token")
export TF_VAR_VAULT_TOKEN=${VAULT_TOKEN}

if [[ $(kubectl --kubeconfig ${KUBECONFIG} --namespace ${ns} get pod --selector="vault-active=true" --output=jsonpath={.items..metadata.name}) ]]; then
    init_inst=$(kubectl --kubeconfig ${KUBECONFIG} --namespace ${ns} get pod --selector="vault-active=true" --output=jsonpath={.items..metadata.name})
    echo "Found Active Vault Node: ${init_inst}"
else
    init_inst="vault-0"
fi
# Setup kubectl port forward to access vault with localhost
if [[ ! $(ps -ef | grep "kubectl port-forward" | grep -v grep) ]]; then
    kubectl port-forward ${init_inst} 8200:8200 > /dev/null 2>&1 &
else
    echo "kubectl port-forward running"
fi