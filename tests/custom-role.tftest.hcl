mock_provider "temporalcloud" {}

run "sets_project_scoped_resource_type" {
  command = plan
  module { source = "./modules/custom-role" }

  variables {
    name = "cr-audit-log-reader"
    permissions = [{
      actions       = ["cloud.account.get"]
      resource_type = "accounts"
      allow_all     = true
    }]
  }

  assert {
    condition     = length(temporalcloud_custom_role.this.permissions) == 1
    error_message = "Expected exactly one permission block."
  }
}

run "rejects_unknown_resource_type" {
  command = plan
  module { source = "./modules/custom-role" }

  variables {
    name = "cr-bad"
    permissions = [{
      actions       = ["cloud.account.get"]
      resource_type = "not-a-real-type"
      allow_all     = true
    }]
  }

  expect_failures = [var.permissions]
}
