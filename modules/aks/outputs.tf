output "azurerm_kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.example.name
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
}

output "client_key" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_key
}

output "username" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.username
}

output "password" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.password
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.example.fqdn
}

output "key_vault_name" {
  value = "${azurerm_key_vault.vault.name}"
}

output "key_vault_key_name" {
  value = "${azurerm_key_vault_key.generated.name}"
}

