#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ ! -z $1 ]]; then
  config="$1"
else
  config="tmp/k8s_config"
fi

# Point to AKS Terraform state file for Auth (RG, Cluster name)
if [[ $(terraform output -state=./terraform.tfstate azure_aks_cluster_name 2>/dev/null) ]]; then
  tfstate="./terraform.tfstate"
  echo "Using ${DIR}/terraform.tfstate"
else
  tfstate="../terraform.tfstate"
  echo "Using ${DIR}/../terraform.tfstate"
fi
MY_RG=$(terraform output -state=${tfstate} resource_group_name)
MY_CN=$(terraform output -state=${tfstate} azure_aks_cluster_name)

# K8s namespace is needed to lookup vault information
if [[ $(terraform output -state=./terraform.tfstate K8s_namespace 2>/dev/null) ]]; then
  ns=$(terraform output K8s_namespace)
  echo "Setting K8s_namespace = ${ns}"
else
  ns="default"
  echo "Setting K8s_namespace = ${ns}"
fi

# you can pass the full path for the k8s_config.  For example: "./tmp/k8s_config"
if [[ -f ${DIR}/$config ]]; then
    rm ${DIR}/$config
fi

echo "Setup K8s Cluster Auth for kubectl"
echo "az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file $config"
az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file $config
export KUBECONFIG=${DIR}/${config}

if [[ $(kubectl --kubeconfig ${DIR}/${config} --namespace ${ns} get pod --selector="vault-active=true" --output=jsonpath={.items..metadata.name}) ]]; then
    init_inst=$(kubectl --kubeconfig ${DIR}/${config} --namespace ${ns} get pod --selector="vault-active=true" --output=jsonpath={.items..metadata.name})
    echo "Found Active Vault Node: ${init_inst}"
else
    init_inst="vault-0"
fi

if [[ -f tmp/cluster-keys.json ]]; then
  export VAULT_ROOT_TOKEN=$(cat tmp/cluster-keys.json | jq -r ".root_token")
  export VAULT_TOKEN=$(kubectl exec -ti ${init_inst} --namespace ${ns} -- vault login ${VAULT_ROOT_TOKEN} -format="json" | jq -r ".auth.client_token")
  kubectl exec -ti ${init_inst} --namespace ${ns} -- vault token lookup
fi