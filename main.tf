#-------------------------------------------------
# Create a resource group
#--------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags = var.tags
}

locals {
  secrets= concat(flatten([ for s in var.StorageAccounts : {
      name="${s.name}-AccessKey", value="${azurerm_storage_account.storage[s.name].primary_access_key}"}
  ]),flatten([for k in var.sql_databases :{
    name="${k.name}-sql-connectionstring",value= "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db[k.name].name};Persist Security Info=False;User ID=${var.admin_username == null ? "sqladmin" : var.admin_username};Password=${random_password.rpassword.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }]),[
        {name="sql-password", value=random_password.rpassword.result},
        #{name="sql-connectionstring", value= "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${var.admin_username == null ? "sqladmin" : var.admin_username};Password=${random_password.rpassword.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"}
    ])
  access_policies=concat( var.enable_system_managed_identity==true ?
    [
      {object_id="${azurerm_app_service.app[0].identity.0.principal_id}",secret_permissions=["Get",],certificate_permissions=[], key_permissions=[],storage_permissions=[] },
      {object_id="${azurerm_app_service.app[1].identity.0.principal_id}",secret_permissions=["Get",],certificate_permissions=[], key_permissions=[],storage_permissions=[] }
    ] : [],var.access_policies) 

    subnet_Ids= [ for i in range(length(var.subnet_prefix)): azurerm_subnet.subnet[i].id ]
}
