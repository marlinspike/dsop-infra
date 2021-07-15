terraform {
  backend "azurerm" {
    use_msi          = false
    use_azuread_auth = true
  }
}
