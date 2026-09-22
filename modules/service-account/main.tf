resource "temporalcloud_service_account" "this" {
  name        = var.name
  description = var.description

  account_access = var.account_access
  # The provider rejects an explicitly empty set for these two (it wants either unset/null or
  # at least one entry), so pass null instead of [] when there's nothing to grant. Not hit by
  # any current caller here (both set account_access_custom_roles), but group-access hit the
  # account_access_custom_roles half of this -- fixed here too so this module doesn't repeat it.
  account_access_custom_roles = length(var.account_access_custom_roles) > 0 ? var.account_access_custom_roles : null
  namespace_accesses          = length(var.namespace_accesses) > 0 ? var.namespace_accesses : null
}
