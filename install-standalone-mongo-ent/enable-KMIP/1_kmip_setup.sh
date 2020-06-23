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
kubectl exec -it vault-0 -- vault write kmip/config listen_addrs=0.0.0.0:5696 server_hostnames="vault"
kubectl exec -it vault-0 -- vault read kmip/config

echo "Retrieve the CA and save to ca.pem"
kubectl exec -it vault-0 -- vault read -field=ca_pem kmip/ca > ca.pem
# pe "vault read -format=json kmip/ca | jq -r .data.ca_pem > ca.pem"
echo

echo "Enable a Scope named, 'salesforce'"
kubectl exec -it vault-0 -- vault write -f kmip/scope/salesforce
kubectl exec -it vault-0 -- vault list kmip/scope
echo "Create a new role, 'admin' under salesforce"
kubectl exec -it vault-0 -- vault write kmip/scope/salesforce/role/admin operation_all=true 
kubectl exec -it vault-0 -- vault list kmip/scope/salesforce/role

echo "Generate the certification and save as client.pem"
kubectl exec -it vault-0 -- vault write -format=json kmip/scope/salesforce/role/admin/credential/generate format=pem_bundle | jq -r .data.certificate > client.pem

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