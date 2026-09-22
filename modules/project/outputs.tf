output "id" {
  description = "Project ID (use as resource_ids in a project-scoped custom role)."
  value       = temporalcloud_project.this.id
}

output "display_name" {
  description = "Project display name."
  value       = temporalcloud_project.this.display_name
}
