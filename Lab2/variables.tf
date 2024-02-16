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
variable "aks_rg" {
  type        = string
  default     = "sme_aks_bpinheiro_rg"
}

## VNETS
variable "vnet_name" {
  type        = string
  default     = "sme_vnet"
}

## AKS
variable "kubernetes_version" {
  type        = string
  description = "The version of kubernetes"
  default     = "1.27.7"
}

variable "node_count" {
  type        = number
  description = "Initial quantity of nodes for the system node pool."
  default     = 1
}

variable "min_node_count" {
  type        = number
  description = "The minimum quantity of nodes for the system node pool."
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "The maximum quantity of nodes for the system node pool."
  default     = 3
}

variable "vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_D2s_v3"
}

variable "service_cidr" {
  type        = string
  description = "Service CIDR for the AKS cluster"
  default     = "10.240.0.0/24"
}

variable "dns_service_ip" {
  type        = string
  description = "AKS cluster DNS service IP"
  default     = "10.240.0.10"
}

variable "outbound_type" {
  type        = string
  description = "AKS cluster Outbound type"
  default     = "loadBalancer"
}

variable "network_plugin" {
  type        = string
  description = "AKS cluster network plugin"
  default     = "azure"
}

variable "network_policy" {
  type        = string
  description = "AKS cluster Network policy"
  default     = "azure"
}

variable "load_balancer_sku" {
  type        = string
  description = "AKS cluster Load balancer SKU"
  default     = "standard"
}
