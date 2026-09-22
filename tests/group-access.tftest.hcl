mock_provider "temporalcloud" {}

run "rejects_invalid_account_access" {
  command = plan
  module { source = "./modules/group-access" }

  variables {
    group_id       = "grp-123"
    account_access = "superadmin"
  }

  expect_failures = [var.account_access]
}
