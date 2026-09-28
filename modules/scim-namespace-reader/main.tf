locals {
  group_name = "az-asbprod-c-user-tmprlnsreader-${var.jogget}-${var.stack}-${var.environment}-r5"
}

# The identity provider creates and synchronizes the group. Terraform looks it up.
data "temporalcloud_scim_group" "reader" {
  idp_id = var.scim_group_idp_id
}

# This resource owns ALL Temporal access assignments for this group.
# Dedicate the group to this one workload namespace.
resource "temporalcloud_group_access" "reader" {
  id             = data.temporalcloud_scim_group.reader.id
  account_access = "none"

  namespace_accesses = [{
    namespace_id = var.namespace_id
    permission   = "read"
  }]

  lifecycle {
    precondition {
      condition     = data.temporalcloud_scim_group.reader.name == local.group_name
      error_message = "The SCIM group ID resolves to a different display name than the workload reader group."
    }
  }
}
