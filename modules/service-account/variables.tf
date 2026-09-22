variable "name" {
  description = "Service account name (e.g. sa-platform-csirt-audit-log-reader-prod)."
  type        = string

  validation {
    condition     = can(regex("^sa-[a-z0-9-]+$", var.name))
    error_message = "Service account names must start with 'sa-' and be lowercase alphanumeric/hyphen."
  }
}

variable "description" {
  description = "Purpose of the service account."
  type        = string
  default     = ""
}

variable "account_access" {
  description = "Built-in account role: admin, developer, read, financeadmin or metricsread. Null when only custom roles are used."
  type        = string
  default     = null
}

variable "account_access_custom_roles" {
  description = "Custom role IDs granted at account level."
  type        = set(string)
  default     = []
}

variable "namespace_accesses" {
  description = "Namespace-level permissions."
  type = set(object({
    namespace_id = string
    permission   = string
  }))
  default = []
}
