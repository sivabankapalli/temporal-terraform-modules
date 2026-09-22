output "admin_role_id" {
  description = "ID of the project-scoped admin custom role."
  value       = module.admin_role.id
}

output "admin_service_account_id" {
  description = "ID of the project admin service account."
  value       = module.admin_service_account.id
}
