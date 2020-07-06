output "azurerm_kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.example.name
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}

output "key_vault_name" {
  value = "${azurerm_key_vault.vault.name}"
}

output "key_vault_key_name" {
  value = "${azurerm_key_vault_key.generated.name}"
}