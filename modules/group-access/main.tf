resource "temporalcloud_group_access" "this" {
  id             = var.group_id
  account_access = var.account_access
  # Same provider quirk as modules/service-account: an empty set is rejected, null is fine --
  # applies to account_access_custom_roles too, not just namespace_accesses (caught when a
  # caller granted account_access alone with no custom roles, e.g. financeadmin with none).
  account_access_custom_roles = length(var.account_access_custom_roles) > 0 ? var.account_access_custom_roles : null
  namespace_accesses          = length(var.namespace_accesses) > 0 ? var.namespace_accesses : null
}
