terraform {
  required_version = ">= 1.6.0"

  required_providers {
    temporalcloud = {
      source  = "temporalio/temporalcloud"
      version = ">= 1.9.0" # temporalcloud_project available from this release
    }
  }
}
