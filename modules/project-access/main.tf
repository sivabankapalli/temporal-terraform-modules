# Composite: project-scoped admin role + admin service account + admin SCIM group access.
# WORKAROUND: temporalcloud_group_access and temporalcloud_service_account have no native
# project-level access yet (tracked upstream as project_accesses; see docs/CONTRIBUTING.md
# in this repo). Until that ships, "project admin" is modelled as an account-level custom
# role scoped to this one project via resource_type = "projects".
locals {
  base_name = "${var.owner}-project-admin-${var.environment}"
}

module "admin_role" {
  source = "../custom-role"

  name        = "cr-project-admin-${var.environment}"
  description = "Administer project ${var.environment}."

  permissions = [{
    actions       = var.project_admin_actions
    resource_type = "projects"
    resource_ids  = [var.project_id]
  }]
}

module "admin_service_account" {
  source = "../service-account"

  name                        = "sa-${local.base_name}"
  description                 = "Project admin automation for ${var.environment}."
  account_access_custom_roles = [module.admin_role.id]
}

module "admin_group_access" {
  source = "../group-access"

  group_id                    = var.admin_group_id
  account_access              = "none"
  account_access_custom_roles = [module.admin_role.id]
}
