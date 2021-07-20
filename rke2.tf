data "azurerm_subnet" "cluster_vnet" {
  resource_group_name  = azurerm_resource_group.base_blueprint.name
  virtual_network_name = "${var.prefix}-${var.spoke_name}-vnet"
  name                 = "workload-subnet"
  depends_on = [
    azurerm_blueprint_assignment.azbf
  ]
}

resource "azurerm_subnet" "cluster_subnet" {
  count                = var.use_built_in_subnet ? 0 : 1
  resource_group_name  = azurerm_resource_group.base_blueprint.name
  virtual_network_name = "${var.prefix}-${var.spoke_name}-vnet"
  name                 = "rke2-subnet"
  address_prefixes     = [var.cluster_subnet_cidr]
  depends_on = [
    azurerm_blueprint_assignment.azbf
  ]
}

module "rke2" {
  source                 = "./dsop-rke2"
  server_public_ip       = var.server_public_ip
  cluster_name           = "${var.prefix}-${var.spoke_name}"
  subnet_id              = var.use_built_in_subnet ? data.azurerm_subnet.cluster_vnet.id : azurerm_subnet.cluster_subnet[0].id
  server_open_ssh_public = var.server_open_ssh_public
  vm_size                = var.vm_size
  agent_vm_size          = var.agent_vm_size
  server_vm_size         = var.server_vm_size
  server_instance_count  = var.server_instance_count
  agent_instance_count   = var.agent_instance_count
  resource_group_name    = azurerm_resource_group.base_blueprint.name
  depends_on = [
    azurerm_blueprint_assignment.azbf
  ]
}
