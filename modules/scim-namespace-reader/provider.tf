terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    temporalcloud = {
      source  = "temporalio/temporalcloud"
      version = "~> 1.9"
    }
  }
}
