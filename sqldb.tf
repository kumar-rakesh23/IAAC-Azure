#-----------------------------------------------------------------------
# create Sql server and Sql data base
#-----------------------------------------------------------------------
resource "random_password" "rpassword" {
  length      = var.random_password_length
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special= 2
  special     = true
  override_special ="_%@!$"
}

#----------------------------------------------------------------------------------------------
#create storage account if var.enable_sql_server_extended_auditing_policy 
#|| var.enable_database_extended_auditing_policy == true
#-----------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_sql_server_extended_auditing_policy ? 1 : 0
  name                      = var.storage_account_name_sql
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.tags
}

resource "azurerm_mssql_server" "sql" {
  name                         = format("%s-%s", var.sqlserver_name,var.environment)
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_login_password = var.admin_password == null ? random_password.rpassword.result : var.admin_password
  tags                         = var.tags
  connection_policy            = var.connection_policy 
   azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
  }
  dynamic "identity" {
    for_each = var.enable_system_managed_identity_sql == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_sql_firewall_rule" "sqlfirewallrule" {
  for_each = {for rule in var.sql_firewall_rules : rule.name => rule }
  name             = each.key
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mssql_server.sql.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address 
}

resource "azurerm_mssql_server_extended_auditing_policy" "auditingpolicy" {
  count                                   = var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_mssql_server.sql.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.retention_days
}

resource "azurerm_mssql_database" "db" {
  for_each = { for db in var.sql_databases : db.name => db }
  name                             = each.key
  server_id                        = azurerm_mssql_server.sql.id
  collation                        = lookup(each.value, "collation", "SQL_Latin1_General_CP1_CI_AS")
  create_mode                      = lookup(each.value, "create_mode", "Default")
  max_size_gb                      = lookup(each.value, "max_size_gb", null)
  sku_name                         = lookup(each.value, "sku_name", null)
  read_scale                       = lookup(each.value, "read_scale", null)
  zone_redundant                   = lookup(each.value, "zone_redundant", null)
  license_type                     = lookup(each.value, "license_type", null)
  tags                             = var.tags

  dynamic "extended_auditing_policy" {
    for_each= each.value.enable_database_extended_auditing_policy==true ? [1] :[]
    content {
      storage_endpoint                        = azurerm_storage_account.storeacc.primary_blob_endpoint
      storage_account_access_key              = azurerm_storage_account.storeacc.primary_access_key
      storage_account_access_key_is_secondary = false
      retention_in_days                       = var.retention_days
    }
  }
  depends_on = [
    azurerm_mssql_server.sql
  ]
}

#------------------------------------------------------------------------
#Applying network rule on azure sql server
#------------------------------------------------------------------------
resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
  count               = length(local.subnet_Ids)
  name                = "${var.sqlserver_name}-vnet-rule-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name           = azurerm_mssql_server.sql.name
  subnet_id           = local.subnet_Ids[count.index]
  depends_on = [
    azurerm_subnet.subnet  
  ]
}