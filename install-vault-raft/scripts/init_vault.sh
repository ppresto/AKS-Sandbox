#!/bin/sh

# Initialize Vault
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ ! -z $1 ]]; then
  config="$1"
else
  config="tmp/k8s_config"
fi

if [[ -f setEnvK8s.sh ]]; then
    . setEnvK8s.sh
else
    echo "Init your K8s Envionment (./scripts/setEnv)"
fi

timeout=300
init_inst="vault-0"
vRunning=""

if [[ ! $(helm status --kubeconfig ${config} vault) ]]; then
    exit 1
fi

isVaultRunning () {
    vRunning=1
    while [ ${timeout} -ge 1 ]
    do
        if [[ $(kubectl get --kubeconfig ${config} pods -o json  | jq -r '.items[] | select(.status.phase != "Running") | .metadata.namespace + "/" + .metadata.name' | wc -l) -gt 0 ]]; then
            timeout=$((${timeout}-5))
            sleep 5
            kubectl get pods
            vRunning=1
        else
            vRunning=0
            return $vRunning
        fi
    done
    return $vRunning
}

initializeVault () {
    vaultInitStatus=$(kubectl --kubeconfig ${config} exec -it ${init_inst} -- vault status | grep Initialized)
    #isInitialized=$(kubectl get pods -o json  | jq -r '.items[] | select(.status.phase == "Running" and select(.metadata.labels."vault-initialized" == "true" )) | .metadata.name')
    #if [[ $(echo $isInitialized | grep "${init_inst}" | grep -v grep) ]]; then
    if [[ $(echo $vaultInitStatus | awk '{ print $NF }' | grep false) ]]; then
        echo "\nInitializing Vault...  (Inititialized Status: $vaultInitStatus)"
        echo
        kubectl exec --kubeconfig ${config} ${init_inst} -- vault operator init -key-shares=1 -key-threshold=1 -format=json > tmp/cluster-keys.json
        sleep 5
        export VAULT_ROOT_TOKEN=$(cat tmp/cluster-keys.json | jq -r ".root_token")
    else
        echo "\nVault Initialized : Skipping..."
    fi
    kubectl exec --kubeconfig ${config} -it ${init_inst} -- vault status
    echo
}

joinRaftPeers() {
    echo "\nChecking for Raft Peers ..."
    podsNotReady=$(kubectl --kubeconfig ${config} get pods -o json  | jq -r '.items[] | select(.status.phase == "Running" and ([ .status.containerStatuses[] | select(.ready == false )] | length ) == 1 ) | .metadata.namespace + "/" + .metadata.name')
    peersNotInit=$(kubectl --kubeconfig ${config} get pods -o json  | jq -r '.items[] | select(.status.phase == "Running" and select(.metadata.labels."vault-initialized" == "false" )) | .metadata.name')
    for peer in $(echo $peersNotInit)
    do
        if [[ $(echo ${podsNotReady} | grep "${peer}") ]]; then 
            echo "\nJoining Peer: ${peer}"
            echo "kubectl exec --kubeconfig ${config} -ti ${peer} -- vault operator raft join http://${init_inst}.vault-internal:8200"
            kubectl exec --kubeconfig ${config} -ti ${peer} -- vault operator raft join http://${init_inst}.vault-internal:8200
            sleep 5
        fi
    done
}

getRaftListPeers() {
    echo "\nVault List Peers"
    export VAULT_ROOT_TOKEN=$(cat tmp/cluster-keys.json | jq -r ".root_token")
    echo $?
    if [[ -z $VAULT_ROOT_TOKEN ]]; then
        echo "Failed to get login token"
        exit
    fi
    export VAULT_TOKEN=$(kubectl exec --kubeconfig ${config} -ti ${init_inst} -- vault login ${VAULT_ROOT_TOKEN} -format="json" | jq -r ".auth.client_token")
    #echo "export VAULT_TOKEN=$(kubectl exec -ti ${init_inst} -- vault login ${VAULT_ROOT_TOKEN} -format='json' | jq -r '.auth.client_token')"
    kubectl exec --kubeconfig ${config} -ti ${init_inst} -- vault operator raft list-peers
}

installLicense () {
    echo "\nChecking Enterprise License\n"
    kubectl port-forward --kubeconfig ${config} vault-0 8200:8200 &
    sleep 5
    cur_lic=$(curl -s --header "X-Vault-Token: ${VAULT_TOKEN}" http://127.0.0.1:8200/v1/sys/license)
    if [[ $(echo $cur_lic | jq -r '.data.license_id' | grep temporary | grep -v grep) ]]; then
        if [[ ! -f tmp/vault-ent.hclic ]]; then
            lic=$(cat ${HOME}/Projects/binaries/vault/patrick.presto_vault_premium.hclic)
tee tmp/vault-ent.hclic <<-EOF
{
  "text": "${lic}"
}
EOF
        fi
        echo $cur_lic | jq -r '.data.license_id'
        echo "\nInstalling License"
        output=$(curl -s \
            --header "X-Vault-Token: ${VAULT_TOKEN}" \
            --request PUT \
            --data @tmp/vault-ent.hclic \
            http://127.0.0.1:8200/v1/sys/license)
        cur_lic=$(curl -s --header "X-Vault-Token: ${VAULT_TOKEN}" http://127.0.0.1:8200/v1/sys/license)
        echo $cur_lic | jq -r

    else
        license_id=$(echo $cur_lic | jq -r '.data.license_id')
        echo "\nLicense Already Installed: ${license_id}"
        echo $cur_lic | jq -r
    fi
    kill $(ps -ef | grep "port-forward" | grep -v grep | awk '{ print $2 }')
}

#
###  Main
#
isVaultRunning
if [[ $? -eq 0 ]]; then
    echo "\nVault is Running"
    kubectl get --kubeconfig ${config} pods
else
    echo "Vault Cluster is not all running.  Exit"
    exit
fi

initializeVault
joinRaftPeers
getRaftListPeers
installLicense