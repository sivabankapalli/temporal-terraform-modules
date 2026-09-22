# Runs without credentials: the provider is mocked.
mock_provider "temporalcloud" {}

variables {
  display_name = "payments"
  description  = "Payments team project."
}

run "creates_project_with_delete_protection_by_default" {
  command = plan
  module {
    source = "./modules/project"
  }

  assert {
    condition     = temporalcloud_project.this.project_lifecycle.enable_delete_protection == true
    error_message = "Delete protection must default to true."
  }
}

run "rejects_invalid_display_name" {
  command = plan
  module {
    source = "./modules/project"
  }

  variables {
    display_name = "Bad Name"
  }

  expect_failures = [var.display_name]
}
