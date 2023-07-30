variable "resource_group_name" {
    type=string
    description = "resource group name"
}

variable "resource_group_location" {
    type=string
    description = "resource group location"
}

variable "app_service_plan_name" {
    type = string
    description = "app service plan name"
  
}
variable "app_service_plan_kind" {
  type = string
  description = " The kind of the App Service Plan to create"
  default = "Windows"
}
variable "app_service_sku" {
    type = object({
        tier=string
        size=string
        })
    description = "tier of app service plan"
    default = {
     tier="Basic"
     size="B1"
    }  
}

variable "tags" {
  type = map(string)
  description = "tag description"
  default = {
    "environment" = "dev"
  }
}

variable "appservice_name" {
    type = list
    description = "name of the app service" 
}

variable "application_insights" {
  type =string
  description = "name of the application insights"
  
}

variable "enable_system_managed_identity" {
    type = bool
    description = "Enable System manged identity in the resource, If want to enable set the value to true else by default it will be false."
    default = false
}

variable "storageaccountname" {
    type = string
    description = "name of the storage account"  
    default = ""
}

variable "containers" {
    type = list(map(string))
    description = "containers details"
    default = []
}

variable "keyvault_Name" {
    type = string
    description = "name of the key vault" 
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 90
  description = "The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 days."
}

variable "sku_name" {
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default = "standard"
}

variable "key_permissions" {
    type = list
    description = "The list of permission to the key."
    default = ["Get",]
  
}

variable "secret_permissions" {
  type = list
    description = "The list of permission to the secret."
    default = ["Get",]
}

variable "storage_permissions" {
  type = list
    description = "The list of permission to the secret."
    default = []
}

variable "secrets" {
  type = list(map(string))
  description = "List of objects that represent the configuration of each secrect."
  default = [  ]
  # secrets = [{ name = "", value = "", content_type="", not_before_date="", expiration_date="'"}]
}

variable "access_policies" {
  description = "define policies for an object_id (user, service principal, security group)"
  type = list(object({
    object_id               = string,
    certificate_permissions = list(string),
    key_permissions         = list(string),
    secret_permissions      = list(string),
    storage_permissions     = list(string),
  }))
  default = []
}
variable "random_password_length" {
    type = number
    description = "length of the password"
    default = 12
}

variable "sqlserver_name" {
    type = string
    description = "name of the sql server"
  
}

variable "environment" {
    type = string
    description = "name of environment eg. dev"
    default = "dev"
  
}

variable "admin_username" {
    type = string
    description = "sql server user name"
    default = null
}

variable "admin_password" {
  type = string
  description = "sql server password"
   default = null
}

variable "enable_system_managed_identity_sql"{
  type = bool
  default = false
}
variable "storage_account_name_sql" {
    type = string
    description = "storage account for sql server/database auditing" 
    default = "sqlserverauditing01"
}

variable "enable_sql_server_extended_auditing_policy" {
    type = bool
    default = false
  
}

variable "retention_days" {
    type = number
    default = 7
  
}

variable "vnetwork_name"{
    type=string
    description="name of the Vnet"
    default="media-vnet"
}

variable "vnet_address_space"{
    description="adress space of the vnet"
    default=["10.0.0.0/16"]
}

variable  "subnet_prefix" {
    type=any
    default = [
    {
      ip      = "10.0.1.0/24"
      name     = "subnet-1"
    },
    {
      ip      = "10.0.2.0/24"
      name     = "subnet-2"
    }
   ]

}

variable "nsgs" {
  type = list
  default = ["networksecuritygroup1","networksecuritygroup2"]
  description = "list of nsg"
}

variable "ips" {
  type=list
  default=[]
  
}

variable "enable_AppService_AutoScale" {
    type = bool
    description = "Enable autoscale feature in the App service plan"
    default = false
}

variable "enabled_for_disk_encryption" {
  type = bool
  description = "Enable disk encryption in the key vault"
  default = false  
}

variable "purge_protection_enabled" {
  type = bool
  description = "Enable Purge protection in the key vault"
  default = false  
}

variable "enabled_for_template_deployment" {
  type = bool
  description = "Enable for template deployment in the key vault"
  default = false 
}

variable "enable_rbac_authorization" {
  type = bool
  description = "Enable RBAC access in the key vault"
  default = false
  
}

variable "network_acls" {
  type = list(object({
    bypass = string
    default_action= string
    ip_rules =list(string)
    virtual_network_subnet_ids=list(string)
  }))
   description = "Network acls details for key vault."
  default = []
}

variable "connection_policy" {
  type = string
  description = "connection policy for the sql server"
  default = "Default"
  
}

variable "sql_firewall_rules" {
  type = list(object({
    name=string
    start_ip_address=string
    end_ip_address=string
  }))
  description = "Firewall rules for the sql server."
  default = [  ]
}

variable "sql_databases" {
  type = list(any)
  description = "List of database to be created."
  default = [  ]
}

variable "StorageAccounts" {
  type = list(any)
  description = "Storage accounts details."
  default = [  ]
}