variable "jogget" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]+(?:-[a-z0-9]+)*$", var.jogget))
    error_message = "jogget must use lowercase letters, numbers, and internal hyphens."
  }
}

variable "stack" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]+(?:-[a-z0-9]+)*$", var.stack))
    error_message = "stack must use lowercase letters, numbers, and internal hyphens."
  }
}

variable "environment" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]+(?:-[a-z0-9]+)*$", var.environment))
    error_message = "environment must use lowercase letters, numbers, and internal hyphens."
  }
}

variable "namespace_id" {
  description = "ID of the workload namespace from the namespace module."
  type        = string
  validation {
    condition     = length(trimspace(var.namespace_id)) > 0
    error_message = "namespace_id is required."
  }
}

variable "scim_group_idp_id" {
  description = "IdP identifier of the existing SCIM group; supply the actual value from the identity provider."
  type        = string
  validation {
    condition     = length(trimspace(var.scim_group_idp_id)) > 0
    error_message = "scim_group_idp_id is required."
  }
}
