terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.8.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "primary" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.environment}-${var.location_short}-pim"
  location = var.location
}

data "azurerm_role_definition" "reader" {
  name = "Reader"
}

data "azurerm_role_definition" "contributor" {
  name = "contributor"
}

resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_management_policy" "contributor" {
  scope              = azurerm_resource_group.this.id
  role_definition_id = data.azurerm_role_definition.contributor.role_definition_id

  eligible_assignment_rules {
    expiration_required = false
  }

  activation_rules {
    maximum_duration      = "PT8H"
    require_approval      = false
    require_justification = true
  }
}

resource "azurerm_pim_eligible_role_assignment" "contributor" {
  scope              = azurerm_resource_group.this.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = data.azurerm_client_config.current.object_id
}
