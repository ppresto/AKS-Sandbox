output "resource_group_id" {
  value = azurerm_resource_group.aks.id
}

output "virtual_network_id" {
  value = azurerm_virtual_network.example.id
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}