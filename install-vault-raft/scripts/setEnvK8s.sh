#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ ! -z $1 ]]; then
  config="$1"
else
  config="tmp/k8s_config"
fi

# Point to AKS Terraform state file for Auth (RG, Cluster name)
if [[ $(terraform output -state=./terraform.tfstate azure_aks_cluster_name) ]]; then
  tfstate="./terraform.tfstate"
  echo "Using ${DIR}/terraform.tfstate"
else
  tfstate="../terraform.tfstate"
  echo "Using ${DIR}/../terraform.tfstate"
fi


MY_RG=$(terraform output -state=${tfstate} resource_group_name)
MY_CN=$(terraform output -state=${tfstate} azure_aks_cluster_name)

# you can pass the full path for the k8s_config.  For example: "./tmp/k8s_config"
if [[ ! -f $config ]]; then
    if [[ ! -d ${config%/*} ]]; then 
        mkdir -p  ${config%/*}
    fi
    echo "az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file $config"
    az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file $config
    export KUBECONFIG=${config}
else
    echo "Authentication Setup"
    echo "export KUBECONFIG=${config}"
    export KUBECONFIG=${config}
    #echo "az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing"
    #az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing
fi
  


#echo -e "\n#\n### UPDATE: main.tf  (If building AKS and Vault with different tfstate)\n#\n"
#echo "key_vault_key_name = $(terraform output -state=../terraform.tfstate key_vault_key_name)"
#echo "key_vault_name = $(terraform output -state=../terraform.tfstate key_vault_name)"