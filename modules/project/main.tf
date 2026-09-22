resource "temporalcloud_project" "this" {
  display_name = var.display_name
  description  = var.description

  project_lifecycle = {
    enable_delete_protection = var.enable_delete_protection
  }
}
