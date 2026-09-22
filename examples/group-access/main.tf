terraform {
  required_providers {
    temporalcloud = { source = "temporalio/temporalcloud", version = ">= 1.9.0" }
  }
}
provider "temporalcloud" {}

variable "group_id" {
  description = "Example input; supply a real SCIM group ID when running against a live account."
  type        = string
  default     = "example-group-id"
}

module "group_access" {
  source = "../../modules/group-access"

  group_id       = var.group_id
  account_access = "financeadmin"
}

output "group_access_id" { value = module.group_access.id }
