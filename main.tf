module "aks" {
  source = "./modules/aks"
  prefix= var.PREFIX
  MY_RG= var.MY_RG
  aks_node_count = var.aks_node_count
  k8s_clustername= var.K8S_CLUSTERNAME
  location = var.LOCATION
  ssh_user = var.SSH_USER
  public_ssh_key_path = var.SSH_USER_PUB_KEY_PATH
  ARM_CLIENT_ID=var.ARM_CLIENT_ID
  ARM_CLIENT_SECRET=var.ARM_CLIENT_SECRET
  ARM_SUBSCRIPTION_ID=var.ARM_SUBSCRIPTION_ID
  ARM_TENANT_ID=var.ARM_TENANT_ID
  my_tags = {
          env = "dev"
          owner = "ppresto"
      }
}

output "aks-fqdn" {
  value = module.aks.fqdn
}

output "azure_aks_cluster_name" {
  value = module.aks.azurerm_kubernetes_cluster_name
}

output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "key_vault_name" {
  value = "${module.aks.key_vault_name}"
}

output "key_vault_key_name" {
  value = "${module.aks.key_vault_key_name}"
}