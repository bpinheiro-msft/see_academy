resource "azurerm_log_analytics_workspace" "law" {
  name                = "smeacademy${var.alias}law"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "acr_diagnostic_settings" {
  name               = "acr_diagnostic_settings"
  target_resource_id = azurerm_container_registry.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category_group = "audit"
  }
  
}