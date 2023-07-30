#---------------------------------------------------
# Create app service plan
#---------------------------------------------------
resource "azurerm_app_service_plan" "appplan" {
  name                = "${var.app_service_plan_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind = var.app_service_plan_kind
  sku {
    tier = var.app_service_sku.tier
    size = var.app_service_sku.size
  }
  tags=var.tags
}
#----------------------------------------------------=
# create app service
#-------------------------------------------------------
resource "azurerm_app_service" "app" {
  count = "${length(var.appservice_name)}"
  name                = "${var.appservice_name[count.index]}-APP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appplan.id

  dynamic "identity" {
    for_each=var.enable_system_managed_identity==true ? [1] : []
    content { 
      type="SystemAssigned"
      }  
  }
  
  site_config {
    dotnet_framework_version = "v4.0"
      dynamic "ip_restriction"{
      for_each= length(regexall("(backend)$", "${var.appservice_name[count.index]}")) > 0 ? [1] : []
      content {
        virtual_network_subnet_id= azurerm_subnet.subnet[count.index].id
        priority=100
        action="Allow"
      } 
    }
  }

  https_only=true
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.appinsights.instrumentation_key}"
  }

  tags=var.tags

  depends_on = [
    azurerm_app_service_plan.appplan,
    azurerm_application_insights.appinsights,
  ]
}

#--------------------------------------------------------------------
#create azure application insight
#--------------------------------------------------------------------
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.application_insights}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}


#-----------------------------------------------------------------------
# Enabling auto sscale in the App service based on the Cpu utlization, 
# When the cpu utlization goes above 75% it will add one instance in the 

#------------------------------------------------------------------------

resource "azurerm_monitor_autoscale_setting" "Appautoscale" {
  count = var.enable_AppService_AutoScale == true ? 1 :0
  name                = format("%s-%s", var.app_service_plan_name,"AutoscaleSetting")
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  target_resource_id  = "${azurerm_app_service_plan.appplan.id}"

  profile {
  name = format("%s-%s", var.app_service_plan_name,"Profile")

  capacity {
    default = 1
    minimum = 1
    maximum = 10
  }

  rule {
    metric_trigger {
      metric_name        = "CpuPercentage"
      metric_resource_id = "${azurerm_app_service_plan.appplan.id}"
      time_grain         = "PT1M"
      statistic          = "Average"
      time_window        = "PT5M"
      time_aggregation   = "Average"
      operator           = "GreaterThan"
      threshold          = 75
    }

    scale_action {
      direction = "Increase"
      type      = "ChangeCount"
      value     = "1"
      cooldown  = "PT1M"
    }
  }

  rule {
    metric_trigger {
      metric_name        = "CpuPercentage"
      metric_resource_id = "${azurerm_app_service_plan.appplan.id}"
      time_grain         = "PT1M"
      statistic          = "Average"
      time_window        = "PT5M"
      time_aggregation   = "Average"
      operator           = "LessThan"
      threshold          = 75
    }

    scale_action {
      direction = "Decrease"
      type      = "ChangeCount"
      value     = "1"
      cooldown  = "PT1M"
    }
  }
  }  
} 