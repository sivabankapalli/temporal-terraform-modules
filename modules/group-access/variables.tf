variable "group_id" {
  description = "Temporal Cloud ID of the SCIM-provisioned group (synced from Entra ID)."
  type        = string
}

variable "account_access" {
  description = "Account role: owner, admin, developer, read, financeadmin or none. NOTE: 'owner' cannot be created/updated via Terraform without Temporal support."
  type        = string

  validation {
    condition     = contains(["owner", "admin", "developer", "read", "financeadmin", "none"], lower(var.account_access))
    error_message = "account_access must be one of owner, admin, developer, read, financeadmin, none."
  }
}

variable "account_access_custom_roles" {
  description = "Custom role IDs granted at account level."
  type        = set(string)
  default     = []
}

variable "namespace_accesses" {
  description = "Namespace-level permissions (admin, write or read)."
  type = set(object({
    namespace_id = string
    permission   = string
  }))
  default = []
}
