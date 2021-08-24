# Using Env TF_VAR_ for :
#ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_I, ARM_TENANT_ID

LOCATION = "West US 2"
PREFIX="ppresto"
MY_RG="aks-1-rg"
K8S_CLUSTERNAME="aks-1"
aks_fqdn = ""
aks_node_count = "5"
k8s_namespace = "default"
vault_name = "ppresto-vault-65f863b0"
key_name = "ppresto-aks-1-rg-key"
# vault-config-type:
# http (default): setups vault using auto-unseal with configmap, no TLS 
# https: setups vault using auto-unseal with secret, TLS configured
vault-config-type = "https"

SSH_USER = "patrickpresto"
SSH_USER_PUB_KEY_PATH = "~/.ssh/id_rsa.pub"
