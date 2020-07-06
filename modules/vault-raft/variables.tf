variable ARM_CLIENT_SECRET {}
variable aks_fqdn {default=""}
variable aks_ca {default=""}
variable aks_client_cert {default=""}
variable aks_client_key {default=""}

variable k8sloadconfig {
    default = ""
}
variable vault_name {
    description = "Get vault_name from Azure Key Vault you created"
}

variable key_name {
    description = "Get key_name from your Azure Key Vault you created"
}