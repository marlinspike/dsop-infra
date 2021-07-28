terraform {
  required_providers {
    azurerm = {
      version = "~> 2.67.0"
      source  = "hashicorp/azurerm"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.2"
    }
  }
}

provider "azurerm" {
  features {}
  environment = var.environment
}

data "azurerm_subscription" "current" {}

locals {
  subscription_id = length(var.subscription_id) > 0 ? var.subscription_id : data.azurerm_subscription.current.id
  nw_location     = length(var.nw_location) > 0 ? var.nw_location : "[parameters('hubLocation')]"
}

resource "azurerm_resource_group" "base_blueprint" {
  name     = "${var.prefix}-${var.spoke_name}-rg"
  location = var.location
}

resource "azurerm_role_definition" "azbf" {
  name  = "azbf-blueprint-role-${var.spoke_name}"
  scope = local.subscription_id

  permissions {
    actions     = ["Microsoft.Authorization/locks/write"]
    not_actions = []
  }

  assignable_scopes = [
    local.subscription_id,
  ]
}

data "azurerm_blueprint_definition" "azbf" {
  name     = "azure-security-benchmark-foundation"
  scope_id = local.subscription_id
}

data "azurerm_blueprint_published_version" "azbf" {
  scope_id       = data.azurerm_blueprint_definition.azbf.scope_id
  blueprint_name = data.azurerm_blueprint_definition.azbf.name
  version        = "1.1-nosc"
}

resource "azurerm_user_assigned_identity" "id" {
  resource_group_name = azurerm_resource_group.base_blueprint.name
  location            = var.location
  name                = "${var.prefix}-${var.spoke_name}-user-identity"
}

resource "azurerm_role_assignment" "operator" {
  scope                = local.subscription_id
  role_definition_name = "Blueprint Operator"
  principal_id         = azurerm_user_assigned_identity.id.principal_id
}

resource "azurerm_role_assignment" "azbf" {
  scope              = local.subscription_id
  role_definition_id = azurerm_role_definition.azbf.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.id.principal_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = local.subscription_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.id.principal_id
}

resource "azurerm_blueprint_assignment" "azbf" {
  name                   = "${var.prefix}-${var.spoke_name}-azbf-assigment"
  target_subscription_id = local.subscription_id
  version_id             = data.azurerm_blueprint_published_version.azbf.id
  location               = var.location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.id.id]
  }

  parameter_values = <<VALUES
    {
        "namePrefix": {
            "value": "${var.prefix}"
        },
        "hubName": {
            "value": "hub"
        },
        "deployHub": {
            "value": ${var.deploy_hub}
        },
        "hub-shared-network-firewall_azureFirewallPrivateIP": {
            "value": "10.0.0.4"
        },
        "destinationAddresses": {
            "value": "0.0.0.0"
        },
        "hub-shared-network-nsg_enableNsgFlowLogs": {
            "value": true
        },
        "hub-shared-network-vnet_vnetAddressPrefix": {
            "value": "10.0.0.0/16"
        },
        "hub-shared-network-vnet_azureFirewallSubnetAddressPrefix": {
            "value": "10.0.0.0/26"
        },
        "hub-shared-network-vnet_bastionSubnetAddressPrefix": {
            "value": "10.0.1.0/27"
        },
        "hub-shared-network-vnet_gatewaySubnetAddressPrefix": {
            "value": "10.0.2.0/24"
        },
        "hub-shared-network-vnet_managementSubnetAddressPrefix": {
            "value": "10.0.3.0/24"
        },
        "hub-shared-network-vnet_jumpBoxSubnetAddressPrefix": {
            "value": "10.0.4.0/24"
        },
        "hub-shared-network-vnet_optionalSubnetNames": {
            "value": []
        },
        "hub-shared-network-vnet_optionalSubnetPrefixes": {
            "value": []
        },
        "enableDdosProtection": {
            "value": ${var.ddos_protection}
        },
        "networkWatcherResourceGroupLocation": {
            "value": "${local.nw_location}"
        },
        "spokeName": {
            "value": "${var.spoke_name}"
        },
        "spoke-workload-network-vnet_spokeVnetAddressPrefix": {
            "value": "${var.spoke_vnet_range}"
        },
        "spoke-workload-network-vnet_spokeSubnetAddressPrefix": {
            "value": "${var.spoke_subnet_range}"
        },
        "spoke-workload-network-vnet_spokeOptionalSubnetNames": {
            "value": []
        },
        "spoke-workload-network-vnet_spokeOptionalSubnetPrefixes": {
            "value": []
        },
        "deploySpoke": {
            "value": ${var.deploy_spoke}
        },
        "hubLocation": {
            "value" : "${var.location}"
        }
    }
  VALUES

  depends_on = [
    azurerm_role_assignment.operator,
    azurerm_role_assignment.contributor,
    azurerm_role_assignment.azbf
  ]
  timeouts {
    create = "180m"
    delete = "180m"
  }
}
