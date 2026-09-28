variable "namespace_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,62}[a-z0-9]$", var.namespace_name))
    error_message = "Provide a valid Temporal namespace name (up to 64 characters)."
  }
}

variable "account_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "retention_days" {
  type    = number
  default = 14
  validation {
    condition     = var.retention_days >= 1 && var.retention_days <= 90 && floor(var.retention_days) == var.retention_days
    error_message = "retention_days must be a whole number between 1 and 90."
  }
}

variable "azure_private_endpoint_resource_id" {
  description = "ARM resource ID identifying exactly one existing connectivity rule in the project."
  type        = string
}
