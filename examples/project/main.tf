terraform {
  required_providers {
    temporalcloud = {
      source  = "temporalio/temporalcloud"
      version = ">= 1.9.0"
    }
  }
}

provider "temporalcloud" {}

module "project" {
  source = "../../modules/project"

  display_name = "example-project"
  description  = "Example project created from the module example."
}

output "project_id" {
  value = module.project.id
}
