module "aks" {
  source = "./modules/aks"
  prefix="ppresto"
  MY_RG="aks-rg"
  k8s_clustername="example-aks1"
  location = "West US 2"
  ssh_user = "patrickpresto"
  public_ssh_key_path = "~/.ssh/id_rsa.pub"
  ARM_CLIENT_ID=var.ARM_CLIENT_ID
  ARM_CLIENT_SECRET=var.ARM_CLIENT_SECRET
  ARM_SUBSCRIPTION_ID=var.ARM_SUBSCRIPTION_ID
  ARM_TENANT_ID=var.ARM_TENANT_ID
  my_tags = {
          env = "dev"
          owner = "ppresto"
      }
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