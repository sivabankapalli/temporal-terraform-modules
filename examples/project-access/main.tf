terraform {
  required_providers {
    temporalcloud = { source = "temporalio/temporalcloud", version = ">= 1.9.0" }
  }
}
provider "temporalcloud" {}

module "project" {
  source        = "../../modules/project"
  display_name  = "project-ci"
  description   = "Example project."
}

module "project_access" {
  source = "../../modules/project-access"

  environment            = "ci"
  project_id              = module.project.id
  project_admin_actions    = ["cloud.account.get"]
  admin_group_id           = "example-group-id"
}
