#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
init_inst="vault-0"
if [[ ! -z $1 ]]; then
  config="$1"
else
  config="tmp/k8s_config"
fi

# Point to AKS Terraform state file for Auth (RG, Cluster name)
if [[ -f ./terraform.tfstate ]]; then
  tfstate="./terraform.tfstate"
  path="."
else
  tfstate="../terraform.tfstate"
  path=".."
fi


MY_RG=$(terraform output -state=${tfstate} resource_group_name)
MY_CN=$(terraform output -state=${tfstate} azure_aks_cluster_name)

# you can pass the full path for the k8s_config.  For example: "./tmp/k8s_config"
if [[ ! -f ${DIR}/${path}/$config ]]; then
    if [[ ! -d ${DIR}/${path}/${config%%/k8s_config} ]]; then 
        mkdir -p  ${DIR}/${path}/${config%%/k8s_config}
    fi
    echo "az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file ${path}/$config"
    az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing --file ${path}/$config
    export KUBECONFIG=${DIR}/${path}/${config}
else
    echo "Authentication Setup"
    echo "export KUBECONFIG=${DIR}/${path}/${config}"
    export KUBECONFIG=${DIR}/${path}/${config}
    export VAULT_ROOT_TOKEN=$(cat ${path}/tmp/cluster-keys.json | jq -r ".root_token")
    export VAULT_TOKEN=$(kubectl exec -ti ${init_inst} -- vault login ${VAULT_ROOT_TOKEN} -format="json" | jq -r ".auth.client_token")
    kubectl exec -ti ${init_inst} -- vault token lookup
    #echo "az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing"
    #az aks get-credentials --resource-group ${MY_RG} --name ${MY_CN} --overwrite-existing
fi
  


#echo -e "\n#\n### UPDATE: main.tf  (If building AKS and Vault with different tfstate)\n#\n"
#echo "key_vault_key_name = $(terraform output -state=../terraform.tfstate key_vault_key_name)"
#echo "key_vault_name = $(terraform output -state=../terraform.tfstate key_vault_name)"