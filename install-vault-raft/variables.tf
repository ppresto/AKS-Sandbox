variable ARM_CLIENT_ID {}
variable ARM_CLIENT_SECRET {}
variable ARM_SUBSCRIPTION_ID {} 
variable ARM_TENANT_ID {}

variable LOCATION {
    default = "West US 2"
}
variable PREFIX {}
variable MY_RG {}
variable K8S_CLUSTERNAME {}
variable aks_fqdn {}
variable SSH_USER {}
variable SSH_USER_PUB_KEY_PATH {}
variable vault_name {
    description = "Azure KeyVault Name for auto unseal"
}
variable key_name {
    description = "Azure Key in KeyVault to be used for auto unseal"
}

variable k8s_namespace {default = "vault"}
variable aks_node_count {default = "3"}

variable vault-config-type {
    description = "default, or tls"
    default = "default"
}