output "id" {
  description = "Custom role ID (use as an entry in account_access_custom_roles)."
  value       = temporalcloud_custom_role.this.id
}

output "name" {
  description = "Custom role name."
  value       = temporalcloud_custom_role.this.name
}
