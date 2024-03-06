## Variables
variable "location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "alias" {
  type        = string
  default     = "bpinheiro"
  description = "Alias"
}

## VM
variable "vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_D2s_v5"
}

variable "vm_admin_username" {
  type        = string
  description = "The admin username for the new vm."
  default     = "azureuser"
}

variable "vm_admin_password" {
  type        = string
  description = "The admin password for vm."
  default     = "adminpass"
}
