# Composite: project-scoped admin role + admin service account + admin SCIM group access.
# WORKAROUND: temporalcloud_group_access and temporalcloud_service_account have no native
# project-level access yet (tracked upstream as project_accesses; see docs/CONTRIBUTING.md
# in this repo). Until that ships, "project admin" is modelled as an account-level custom
# role scoped to this one project via resource_type = "projects".
locals {
  base_name = "${var.owner}-project-admin-${var.environment}"
}

module "admin_role" {
  source = "C:/siva/solutions/temporal/source/temporal-terraform-modules/modules/custom-role"

  name        = "cr-project-admin-${var.environment}"
  description = "Administer project ${var.environment}."

  permissions = [{
    actions       = var.project_admin_actions
    resource_type = "projects"
    resource_ids  = [var.project_id]
  }]
}

module "admin_service_account" {
  source = "C:/siva/solutions/temporal/source/temporal-terraform-modules/modules/service-account"

  name        = "sa-${local.base_name}"
  description = "Project admin automation for ${var.environment}."
  # Same requirement as the two account-level service accounts in the PoC caller: the provider
  # needs account_access or namespace_scoped_access set, a custom role alone isn't enough.
  account_access              = "read"
  account_access_custom_roles = [module.admin_role.id]
}

module "admin_group_access" {
  source = "C:/siva/solutions/temporal/source/temporal-terraform-modules/modules/group-access"

  group_id = var.admin_group_id
  # "none" + a non-empty account_access_custom_roles is rejected server-side ("invalid account
  # role") -- ROLE_UNSPECIFIED apparently can't be sent explicitly alongside custom roles, only
  # omitted entirely (which the module only does when there are zero custom roles too). "read"
  # is the narrowest real role available, narrowed further in practice by the custom role.
  account_access              = "read"
  account_access_custom_roles = [module.admin_role.id]
}
