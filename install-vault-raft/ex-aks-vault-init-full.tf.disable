module "aks" {
  source = "../modules/aks"
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

module "vault-raft" {
  source = "../modules/vault-raft"
  k8s_namespace = var.k8s_namespace
  k8sloadconfig = "false"
  aks_fqdn = module.aks.fqdn
  aks_ca = module.aks.cluster_ca_certificate
  aks_client_cert = module.aks.client_certificate
  aks_client_key = module.aks.client_key
  vault_name = module.aks.key_vault_name
  key_name = module.aks.key_vault_key_name
  ARM_CLIENT_SECRET=var.ARM_CLIENT_SECRET
  vault-config-type = var.vault-config-type
}

variable "config_path" {
  description = "path to a kubernetes config file"
  default = "tmp/k8s_config"
}

resource "null_resource" "init-vault" {
  triggers = {
    config_contents = filemd5("${path.module}/scripts/init_vault.sh")
  }
  depends_on = [module.vault-raft]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setEnvK8s.sh ${path.module}/${var.config_path}; ${path.module}/scripts/init_vault.sh ${path.module}/${var.config_path}"
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
  value = module.aks.key_vault_name
}

output "key_vault_key_name" {
  value = module.aks.key_vault_key_name
}

output "helm-status" {
  value = module.vault-raft.status
}
output "helm-name" {
  value = module.vault-raft.name
}
output "helm-version" {
  value = module.vault-raft.version
}
output "K8s_namespace" {
  value = module.vault-raft.K8s_namespace
}
output "vault-addr" {
  value = "${var.vault-config-type}://127.0.0.1:8200"
}