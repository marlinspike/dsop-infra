output "rke2_cluster" {
  value = module.rke2.rke2_cluster
}

output "kv_name" {
  value = module.rke2.kv_name
}

output "cert_key_id" {
  value = var.provision_dns ? azurerm_key_vault_secret.key[0].id : ""
}

output "cert_crt_id" {
  value = var.provision_dns ? azurerm_key_vault_secret.crt[0].id : ""
}
