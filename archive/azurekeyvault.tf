resource "random_id" "keyvault" {
  byte_length = 4
}

resource "azurerm_key_vault" "vault" {
  name                        = "${var.prefix}-vault-${random_id.keyvault.hex}"
  location                    = azurerm_resource_group.aks.location
  resource_group_name         = azurerm_resource_group.aks.name
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  tags = {
    environment = "${var.prefix}"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id

    #object_id = "${var.object_id}"
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
      "create",
      "delete",
      "update",
      "wrapKey",
      "unwrapKey",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "azurerm_key_vault_key" "generated" {
  name         = "${var.prefix}-${var.MY_RG}-key"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}