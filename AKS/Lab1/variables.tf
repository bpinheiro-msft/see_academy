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
variable "netcore_rg" {
  type        = string
  default     = "sme_netcore_bpinheiro_rg"
}

variable "core_rg" {
  type        = string
  default     = "sme_core_bpinheiro_rg"
}

variable "aks_rg" {
  type        = string
  default     = "sme_aks_bpinheiro_rg"
}

## VNETS
variable "vnet_hub_name" {
  type        = string
  default     = "sme_vnet_hub"
}

variable "vnet_aks_name" {
  type        = string
  default     = "sme_vnet_aks"
}   

## FW
variable "zones" {
  description = "Specifies the availability zones of the Azure Firewall"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "sku_name" {
  description = "(Required) SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet. Changing this forces a new resource to be created."
  default     = "AZFW_VNet"
  type        = string
  validation {
    condition = contains(["AZFW_Hub", "AZFW_VNet" ], var.sku_name)
    error_message = "The value of the sku name property of the firewall is invalid."
  }
}

variable "sku_tier" {
  description = "(Required) SKU tier of the Firewall. Possible values are Premium, Standard, and Basic."
  default     = "Standard"
  type        = string
  validation {
    condition = contains(["Premium", "Standard", "Basic" ], var.sku_tier)
    error_message = "The value of the sku tier property of the firewall is invalid."
  }
}

variable "threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
  default     = "Alert"
  type        = string
  validation {
    condition = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
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
variable "vm_admin_username" {
  type        = string
  description = "The admin username for the new vm."
  default     = "azureuser"
}

variable "vm_dns_admin_password" {
  type        = string
  description = "The admin password for the new vm."
  default     = "adminpass123"
}

variable "vm_jb_admin_password" {
  type        = string
  description = "The admin password for the new vm."
  default     = "adminpass123"
}
