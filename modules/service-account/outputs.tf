output "id" {
  description = "Service account ID."
  value       = temporalcloud_service_account.this.id
}

output "name" {
  description = "Service account name."
  value       = temporalcloud_service_account.this.name
}
