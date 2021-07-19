data "azurerm_subnet" "cluster_vnet" {
  resource_group_name  = azurerm_resource_group.base_blueprint.name
  virtual_network_name = "${var.prefix}-${var.spoke_name}-vnet"
  name                 = "workload-subnet"
  depends_on = [
    azurerm_blueprint_assignment.azbf
  ]
}

module "rke2" {
  source                 = "./dsop-rke2"
  server_public_ip       = var.server_public_ip
  cluster_name           = "${var.prefix}-${var.spoke_name}"
  subnet_id              = data.azurerm_subnet.cluster_vnet.id
  server_open_ssh_public = var.server_open_ssh_public
  vm_size                = var.vm_size
  server_instance_count  = var.server_instance_count
  agent_instance_count   = var.agent_instance_count
  resource_group_name    = azurerm_resource_group.base_blueprint.name
  depends_on = [
    azurerm_blueprint_assignment.azbf
  ]

}
