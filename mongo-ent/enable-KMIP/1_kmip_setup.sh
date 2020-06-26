#!/bin/bash
DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MONGO_DB_DATA="/data/db"
MONGO_LOG="mongodb.log"

if [[ -f ${DIRECTORY}/ca.pem ]]; then
    rm -rf ${DIRECTORY}/*.pem
fi

echo "Enable Vault Audit Logging"
kubectl exec -it vault-0 -- vault audit enable file file_path=/vault/logs/vault_audit.log

echo "Enable KMIP"
kubectl exec -it vault-0 -- vault secrets enable kmip
kubectl exec -it vault-0 -- vault write kmip/config listen_addrs=0.0.0.0:5696 server_hostnames="vault-kmip"
kubectl exec -it vault-0 -- vault read kmip/config

echo "Retrieve the CA and save to ca.pem"
kubectl exec -it vault-0 -- vault read -field=ca_pem kmip/ca | awk '{$1=$1};1' > vault-ca-kmip.pem

echo "Enable a Scope named, 'tenant_1'"
kubectl exec -it vault-0 -- vault write -f kmip/scope/tenant_1
kubectl exec -it vault-0 -- vault list kmip/scope
echo "Create a new role, 'admin' under tenant_1"
kubectl exec -it vault-0 -- vault write kmip/scope/tenant_1/role/admin operation_all=true 
kubectl exec -it vault-0 -- vault list kmip/scope/tenant_1/role

echo "Generate the certificate for tenant_1 and save as vault_cert_tenant_1.pem"
kubectl exec -it vault-0 -- vault write -format=json kmip/scope/tenant_1/role/admin/credential/generate format=pem_bundle | jq -r .data.certificate > vault-cert-tenant-1.pem

echo "Create a configmap with the ca and the tenant_1 cert our pod will use"
kubectl create configmap vault-certs-for-kmip --from-file=./vault-cert-tenant-1.pem --from-file=./vault-ca-kmip.pem

#mongod --dbpath ${MONGO_DB_DATA}  \
#    --enableEncryption \
#    --kmipServerName localhost \
#     --kmipPort 5696 \
#     --kmipServerCAFile ${DIRECTORY}/ca.pem \
#     --kmipClientCertificateFile ${DIRECTORY}/client.pem \
#     --fork --logpath ${DIRECTORY}/${MONGO_LOG}

# --enableEncryption --kmipServerName localhost --kmipPort 5696  --kmipServerCAFile ./ca.pem --kmipClientCertificateFile ./client.pem
kmip=$(cat ${DIRECTORY}/${MONGO_LOG} | grep "Created KMIP key with id" | awk '{ print $NF }')

echo "Verify the Encryption Key Manager is initialized"
cat ${DIRECTORY}/${MONGO_LOG} | grep -i kmip

echo "View Vault Audit Log"
cat /tmp/vault_audit.log | jq