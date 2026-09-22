variable "environment" {
  description = "Environment code this project belongs to (ci, dev, qa, prod). Used to derive resource names."
  type        = string
}

variable "owner" {
  description = "Team that owns the project-admin automation. Matches the sa-<owner>-... naming convention."
  type        = string
  default     = "platform"
}

variable "project_id" {
  description = "ID of the project (from the project module) that the admin role is scoped to."
  type        = string
}

variable "project_admin_actions" {
  description = "Actions granted by the per-project admin role. UNCONFIRMED: the provider docs show only cloud.account.get as an example; verify the real action strings before relying on this."
  type        = set(string)
}

variable "admin_group_id" {
  description = "Temporal Cloud ID of the SCIM group that administers this project (e.g. from a temporalcloud_scim_group data source)."
  type        = string
}
