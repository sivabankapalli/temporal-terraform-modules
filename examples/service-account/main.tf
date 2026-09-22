terraform {
  required_providers {
    temporalcloud = { source = "temporalio/temporalcloud", version = ">= 1.9.0" }
  }
}
provider "temporalcloud" {}

module "service_account" {
  source = "../../modules/service-account"

  name           = "sa-platform-metrics-reader-ci"
  description    = "Metrics scraper."
  account_access = "metricsread"
}

output "service_account_id" { value = module.service_account.id }
