## Variables
variable "location" {
  type        = string
  default     = "uksouth"
  description = "Location of the resource group."
}

variable "alias" {
  type        = string
  default     = "bpinheiro"
  description = "Alias"
}

## Resource groups
variable "rg" {
  type        = string
  default     = "SME-SEEAcademy-ACR-1"
}

## AKS
variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "kubernetes_version" {
  type        = string
  description = "The version of kubernetes"
  default     = "1.27.7"
}

variable "vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_D2s_v3"
}

## VM
variable "vm_push_name" {
  type        = string
  description = "The push VM name."
  default     = "PushVM"
}

variable "vm_pull_name" {
  type        = string
  description = "The push VM name."
  default     = "PullVM"
}

variable "vm_admin_username" {
  type        = string
  description = "The admin username for the new vm."
  default     = "azureuser"
}

variable "vm_pull_admin_password" {
  type        = string
  description = "The admin password for the pull vm."
  default     = "adminpass"
}

variable "vm_push_admin_password" {
  type        = string
  description = "The admin password for the push vm."
  default     = "adminpass"
}

