#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
init_inst="vault-0"
if [[ ! -z $1 ]]; then
  config="$1"
else
  config="${HOME}/.kube/config"
fi

MY_RG=$(terraform output resource_group_name)
MY_CN=$(terraform output azure_aks_cluster_name)

# you can pass the full path for the k8s_config.  For example: "./tmp/k8s_config"
if [[ -f ${DIR}/$config ]]; then
    rm ${DIR}/$config
fi

echo "Setup K8s Cluster Auth for kubectl"
echo "az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file $config"
az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file $config
export KUBECONFIG=${config}
