# hcs-az-dev

## Pre Req
* Azure Subscription 

## Build AKS Cluster

## Connect to AKS
```
az login
az aks get-credentials --resource-group hcs-ppresto-rg --name example-aks1
```

## Install Vault
```
helm repo add hashicorp https://helm.releases.hashicorp.com

helm install vault hashicorp/vault \
  --set='server.image.repository=hashicorp/vault-enterprise' \
  --set='server.image.tag=1.4.2_ent' \
  --set='server.ha.enabled=true' \
  --set='server.ha.raft.enabled=true'

kubectl exec vault-0 -- vault status
```
### Initialize & Unseal Vault Master
```
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
VAULT_ROOT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")

kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
```

### Join & Unseal Vault Cluster
```
kubectl exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -ti vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY

kubectl exec -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -ti vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl get pods
```

### Login and test Vault
Login to vault and save token to env var.
```
VAULT_TOKEN=$(kubectl exec -ti vault-0 -- vault login ${VAULT_ROOT_TOKEN} -format="json" | jq -r ".auth.client_token")

kubectl exec -ti vault-0 -- vault operator raft list-peers
```

### Install license
Setup a port-forward tunnel from your machine (keep this process in forground)
```
kubectl port-forward vault-0 8200:8200
```
In a new terminal window source necessary environment info for vault.  Create the vault license key json payload.

vault-ent.lic
```
{
  "text": "01ABCDEFG..."
}
```

Using the Vault API from your machine (port-forward tunnel) input YOUR_TOKEN and write the license
```
curl \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request PUT \
  --data @vault-ent.lic \
  http://127.0.0.1:8200/v1/sys/license
```

Read the license
```
curl \
  --header "X-Vault-Token: ${VAULT_TOKEN}" \
  http://127.0.0.1:8200/v1/sys/license
```