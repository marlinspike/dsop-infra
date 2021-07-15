variable "prefix" {
  type    = string
  default = "dpos"
}

variable "environment" {
  type    = string
  default = "usgovernment"
}

variable "location" {
  type    = string
  default = "usgovvirginia"
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "nw_location" {
  type    = string
  default = ""
}

variable "deploy_hub" {
  type    = bool
  default = false
}

variable "spoke_name" {
  type = string
}

variable "spoke_vnet_range" {
  type = string
}

variable "spoke_subnet_range" {
  type = string
}
