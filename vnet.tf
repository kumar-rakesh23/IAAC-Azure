#-------------------------------------
# VNET Creation 
#-------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetwork_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

#----------------------------------------------
# Subnet 
#enable service end point
#add delegation type on one of the subnet for vent integration on the fronted webapp
#-----------------------------------------------

resource "azurerm_subnet" "subnet" {
    name = "${lookup(element(var.subnet_prefix, count.index), "name")}"
    count = length(var.subnet_prefix)
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "${lookup(element(var.subnet_prefix, count.index), "ip")}"
    service_endpoints= lookup(element(var.subnet_prefix, count.index), "service_endpoints", [])
    
    dynamic "delegation" {
    for_each = lookup(element(var.subnet_prefix, count.index), "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(element(var.subnet_prefix, count.index).delegation, "name", null)
      service_delegation {
        name    = lookup(element(var.subnet_prefix, count.index).delegation.service_delegation, "name", null)
        actions = lookup(element(var.subnet_prefix, count.index).delegation.service_delegation, "actions", null)
      }
    }
  }
}

#--------------------------------------------------------------------
#create net work security group
#--------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  count = length(var.nsgs)
  name                = element(var.nsgs,count.index)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags=var.tags

}

#----------------------------------------------------------------------
#associate nsg to subnet
#----------------------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  count = length(var.nsgs)
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
}

#-----------------------------------------------------------------------
#vnet integration in the app service so that all the outbound communication will be through private vnet.
#-----------------------------------------------------------------------
resource "azurerm_app_service_virtual_network_swift_connection" "frontedappvnetintegration" {
  app_service_id = azurerm_app_service.app[0].id
  subnet_id      = azurerm_subnet.subnet[1].id
}
