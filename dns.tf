provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "dns_private_key" {
  count     = var.provision_dns ? 1 : 0
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  count           = var.provision_dns ? 1 : 0
  account_key_pem = tls_private_key.dns_private_key[0].private_key_pem
  email_address   = "dns-provider@${var.domain_name}"
}

resource "acme_certificate" "certificate" {
  count                     = var.provision_dns ? 1 : 0
  account_key_pem           = acme_registration.reg[0].account_key_pem
  common_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}", "*.admin.${var.domain_name}", var.domain_name]

  dns_challenge {
    provider = "azure"
    config = {
      AZURE_CLIENT_ID       = var.dns_azure_client_id
      AZURE_CLIENT_SECRET   = var.dns_azure_client_secret
      AZURE_SUBSCRIPTION_ID = var.dns_azure_subscription_id
      AZURE_TENANT_ID       = var.dns_azure_tenant_id
      AZURE_RESOURCE_GROUP  = var.dns_azure_resource_group
    }
  }
}

data "azurerm_key_vault" "this" {
  resource_group_name = module.rke2.rg_name
  name                = module.rke2.kv_name
}

# Wait 20 seconds for permission to be granted
resource "time_sleep" "wait_20_seconds_keyvault" {
  depends_on = [data.azurerm_key_vault.this]

  create_duration = "20s"
}


resource "azurerm_key_vault_secret" "crt" {
  count        = var.provision_dns ? 1 : 0
  name         = "rke2-domain-crt"
  key_vault_id = data.azurerm_key_vault.this.id
  value        = base64encode("${acme_certificate.certificate[0].certificate_pem}${acme_certificate.certificate[0].issuer_pem}")
  depends_on = [
    time_sleep.wait_20_seconds_keyvault
  ]
}


resource "azurerm_key_vault_secret" "key" {
  count        = var.provision_dns ? 1 : 0
  name         = "rke2-domain-key"
  key_vault_id = data.azurerm_key_vault.this.id
  value        = base64encode(acme_certificate.certificate[0].private_key_pem)
  depends_on = [
    time_sleep.wait_20_seconds_keyvault
  ]
}
