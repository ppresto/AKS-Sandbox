#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
vaultInstallDir="../../install-vault-raft"

if [[ ! -z $1 ]]; then
    export VAULT_NAMESPACE="$1"
    echo "VAULT_NAMESPACE = $VAULT_NAMESPACE"
fi

export KUBECONFIG=${DIR}/${vaultInstallDir}/tmp/k8s_config
#export KUBECONFIG=/Users/patrickpresto/Projects/AKS-Sandbox/install-vault/scripts/../tmp/k8s_config
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN=$(cat ${DIR}/${vaultInstallDir}/tmp/cluster-keys.json| jq -r ".root_token")
export TF_VAR_VAULT_ADDR=${VAULT_ADDR}
export TF_VAR_VAULT_TOKEN=${VAULT_ROOT_TOKEN}

# Setup kubectl port forward to access vault with localhost

if [[ ! $(ps -ef | grep "kubectl port-forward" | grep -v grep) ]]; then
    kubectl port-forward vault-0 8200:8200 > /dev/null 2>&1 &
else
    echo "kubectl port-forward already running"
fi

#echo "Enable Vault Audit Logging"
#vault audit enable file file_path=/vault/logs/vault_audit.log

echo "Enable KMIP"
vault secrets enable kmip
vault write kmip/config listen_addrs=0.0.0.0:5696 server_hostnames="vault-kmip"

if [[ -f ${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem ]]; then
    rm ${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem
fi

echo "Retrieve the CA and save to ca.pem"
if [[ -z ${VAULT_NAMESPACE} ]]; then
    curl -s\
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --request GET \
        http://127.0.0.1:8200/v1/kmip/ca \
        | jq -r ".data.ca_pem" > ${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem
else
    curl -s\
        --header "X-Vault-Token: ${VAULT_TOKEN}" \
        --header "X-Vault-Namespace: ${VAULT_NAMESPACE}" \
        --request GET \
        http://127.0.0.1:8200/v1/kmip/ca \
        | jq -r ".data.ca_pem" > ${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem
        #| awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' > ${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem
        # ^^ awk syntax replaces newlines with \n for proper formatting
fi

echo "Enable a Scope named, 'tenant_1'"
vault write -f kmip/scope/tenant_1
# kubectl exec -it vault-0 -- vault list kmip/scope
echo "Create a new role, 'admin' under tenant_1"
vault write kmip/scope/tenant_1/role/admin operation_all=true 
vault list kmip/scope/tenant_1/role
if [[ -f ${DIR}/${vaultInstallDir}/tmp/vault-cert-tenant-1.pem ]]; then
    rm ${DIR}/${vaultInstallDir}/tmp/vault-cert-tenant-1.pem
fi
echo "Generate the certificate for tenant_1 and save as vault_cert_tenant_1.pem"
vault write -format=json kmip/scope/tenant_1/role/admin/credential/generate format=pem_bundle \
    | jq -r .data.certificate > ${DIR}/${vaultInstallDir}/tmp/vault-cert-tenant-1.pem
    #| awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' > ${DIR}/${vaultInstallDir}/tmp/vault-cert-tenant-1.pem

if [[ ! $(vault kv get -format="json" kv/database/config | jq -r '.data.vault-ca-kmip') ]]; then
    echo "Add KMIP CA and Client Certs to Vault KV"
    vault kv put kv/database/certs/ca vault-ca-kmip=@${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem
    vault kv put kv/database/certs/client vault-cert-tenant-1=@${DIR}/${vaultInstallDir}/tmp/vault-cert-tenant-1.pem
else
    echo "Found: KMIP Certs already in Vault"
fi

# Configmap isn't secure.  Can be used as example if Vault isn't available.
#echo "Create a configmap with the ca and the tenant_1 cert our pod will use"
#kubectl delete configmap vault-certs-for-kmip
#kubectl create configmap vault-certs-for-kmip --from-file=${DIR}/${vaultInstallDir}/tmp/vault-cert-tenant-1.pem --from-file=${DIR}/${vaultInstallDir}/tmp/vault-ca-kmip.pem
