variable "display_name" {
  description = "Display name of the Temporal Cloud project (e.g. payments)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.display_name))
    error_message = "display_name must be lowercase alphanumeric/hyphen, 2-31 characters, starting with a letter."
  }
}

variable "description" {
  description = "What the project is for / who owns it."
  type        = string
  default     = ""
}

variable "enable_delete_protection" {
  description = "Prevent accidental deletion of the project."
  type        = bool
  default     = true
}
