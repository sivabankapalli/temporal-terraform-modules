output "group_name" {
  value = local.group_name
}

output "group_id" {
  value = data.temporalcloud_scim_group.reader.id
}

output "namespace_permission" {
  value = "read"
}
