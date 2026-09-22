variable "name" {
  description = "Name of the custom role (e.g. cr-audit-log-reader-role)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,62}$", var.name))
    error_message = "name must be lowercase alphanumeric/hyphen, 3-63 characters, starting with a letter."
  }
}

variable "description" {
  description = "Purpose of the role."
  type        = string
  default     = ""
}

variable "permissions" {
  description = "Permission blocks. Each grants actions on a scope of resources."
  type = list(object({
    actions       = set(string)
    resource_type = string
    resource_ids  = optional(set(string), [])
    allow_all     = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for p in var.permissions : contains(
        ["accounts", "projects", "namespaces", "nexus-endpoints", "connectivity-rules", "custom-roles"],
        p.resource_type
      )
    ])
    error_message = "resource_type must be one of accounts, projects, namespaces, nexus-endpoints, connectivity-rules, custom-roles."
  }
}
