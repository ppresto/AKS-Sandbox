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