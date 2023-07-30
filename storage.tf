#-----------------------------------------------------------------
# create storage account
#-----------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  for_each = {for s in var.StorageAccounts : s.name => s}
  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = each.value.account_tier
  account_replication_type = lookup(each.value, "account_replication_type", "LRS")
  network_rules {
    default_action  = lookup(each.value, "default_action" , "Allow") 
    ip_rules        = lookup(each.value, "ip_rules", []) 
    virtual_network_subnet_ids = concat(lookup(each.value, "virtual_network_subnet_ids",[]), local.subnet_Ids)  
    bypass = lookup(each.value, "bypass",["Metrics","AzureServices"])                   
  }
  tags = var.tags
}

#------------------------------------------------------------------------
# create multiple container
#-------------------------------------------------------------------------

resource "azurerm_storage_container" "storagecontainer" {
  for_each = {for container in var.containers: container.name => container}
  name                  = each.value.name
  storage_account_name  = each.value.storage_account_name
  container_access_type = each.value.container_access_type
}