resource "temporalcloud_group_access" "this" {
  id                          = var.group_id
  account_access              = var.account_access
  account_access_custom_roles = var.account_access_custom_roles
  namespace_accesses          = var.namespace_accesses
}
