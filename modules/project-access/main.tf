# Composite: project-scoped admin role + admin service account + admin SCIM group access.
# WORKAROUND: temporalcloud_group_access and temporalcloud_service_account have no native
# project-level access yet (tracked upstream as project_accesses; see docs/CONTRIBUTING.md
# in this repo). Until that ships, "project admin" is modelled as an account-level custom
# role scoped to this one project via resource_type = "projects".
#
# LOCAL POC ONLY: sources below are absolute paths, not the "../module-name" this file ships
# with in the real repo. Terraform treats an absolute-path module as its own package and won't
# let "../" escape it, so the normal relative sources fail here. Revert to "../custom-role" etc.
# before this file goes anywhere near the real temporal-tf-modules repo.
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
  # The provider requires account_access or namespace_scoped_access set; a custom role alone
  # isn't enough.
  account_access              = "read"
  account_access_custom_roles = [module.admin_role.id]
}

module "admin_group_access" {
  source = "C:/siva/solutions/temporal/source/temporal-terraform-modules/modules/group-access"

  group_id                    = var.admin_group_id
  account_access              = "none"
  account_access_custom_roles = [module.admin_role.id]
}
