# Policy for CIS banchmark
data "azurerm_policy_set_definition" "cis" {
  name = "612b5213-9160-4969-8578-1518bd2a000c"
}

# Policy for NIST 800-53
data "azurerm_policy_set_definition" "nist_800_53" {
  name = "cf25b9c1-bd23-4eb6-bd2c-f4f3ac644a5f"
}

resource "azurerm_resource_group_policy_assignment" "cis" {
  name                 = "cis-pa-${azurerm_resource_group.base_blueprint.name}"
  resource_group_id    = azurerm_resource_group.base_blueprint.id
  policy_definition_id = data.azurerm_policy_set_definition.cis.id
  description          = "Policy Assignment of CIS"
  display_name         = "Policy Assignment of CIS at ${azurerm_resource_group.base_blueprint.name}"
}

resource "azurerm_resource_group_policy_assignment" "nist_800_53" {
  name                 = "nist-800-53-pa-${azurerm_resource_group.base_blueprint.name}"
  resource_group_id    = azurerm_resource_group.base_blueprint.id
  location             = azurerm_resource_group.base_blueprint.location
  policy_definition_id = data.azurerm_policy_set_definition.nist_800_53.id
  description          = "Policy Assignment of NIST 800-53"
  display_name         = "Policy Assignment of NIST 800-53 at ${azurerm_resource_group.base_blueprint.name}"
  identity {
    type = "SystemAssigned"
  }
}

