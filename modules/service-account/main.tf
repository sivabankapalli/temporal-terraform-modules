resource "temporalcloud_service_account" "this" {
  name        = var.name
  description = var.description

  account_access              = var.account_access
  account_access_custom_roles = var.account_access_custom_roles
  namespace_accesses          = var.namespace_accesses
}
