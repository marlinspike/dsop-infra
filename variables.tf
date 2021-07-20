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

variable "deploy_spoke" {
  type    = bool
  default = true
}

variable "ddos_protection" {
  type    = bool
  default = false
}



variable "cloud" {
  description = "Which Azure cloud to use"
  type        = string
  default     = "AzureUSGovernmentCloud"
  validation {
    condition     = contains(["AzureUSGovernmentCloud", "AzurePublicCloud"], var.cloud)
    error_message = "Allowed values for cloud are \"AzureUSGovernmentCloud\" or \"AzurePublicCloud\"."
  }
}

variable "server_public_ip" {
  description = "Assign a public IP to the control plane load balancer"
  type        = bool
  default     = false
}

variable "server_open_ssh_public" {
  description = "Allow SSH to the server nodes through the control plane load balancer"
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "Default VM size to use for the cluster"
  type        = string
  default     = "Standard_D8_v3"
}

variable "server_vm_size" {
  type        = string
  description = "VM size to use for the server nodes"
  default     = ""
}

variable "agent_vm_size" {
  type        = string
  description = "VM size to use for the agent nodes"
  default     = ""
}

variable "server_instance_count" {
  type    = number
  default = 1
}

variable "agent_instance_count" {
  type    = number
  default = 2
}

variable "use_built_in_subnet" {
  description = "If True will use the built in subnet instead of creating a cluster subnet"
  type        = bool
  default     = false
}

variable "cluster_subnet_cidr" {
  description = "The CIDR for the cluster subnet"
  type        = string
  default     = "10.0.0.0/24"
}
