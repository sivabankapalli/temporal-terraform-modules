terraform {
  required_providers {
    temporalcloud = { source = "temporalio/temporalcloud", version = ">= 1.9.0" }
  }
}
provider "temporalcloud" {}

module "custom_role" {
  source = "../../modules/custom-role"

  name        = "cr-audit-log-reader"
  description = "Read audit logs."
  permissions = [{
    actions       = ["cloud.account.get"]
    resource_type = "accounts"
    allow_all     = true
  }]
}

output "custom_role_id" { value = module.custom_role.id }
