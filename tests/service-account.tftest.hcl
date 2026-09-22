mock_provider "temporalcloud" {}

run "rejects_name_without_sa_prefix" {
  command = plan
  module { source = "./modules/service-account" }

  variables {
    name = "platform-metrics-reader-ci"
  }

  expect_failures = [var.name]
}
