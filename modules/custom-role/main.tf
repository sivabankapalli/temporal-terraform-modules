resource "temporalcloud_custom_role" "this" {
  name        = var.name
  description = var.description

  permissions = [
    for p in var.permissions : {
      actions = p.actions
      resources = {
        resource_type = p.resource_type
        resource_ids  = p.resource_ids
        allow_all     = p.allow_all
      }
    }
  ]
}
