locals {
  request = {
    namespace_name                     = var.namespace_name
    account_id                         = var.account_id
    project_id                         = var.project_id
    region                             = var.region
    retention_days                     = var.retention_days
    azure_private_endpoint_resource_id = var.azure_private_endpoint_resource_id
  }
}

# Terraform records the invocation. The Python helper makes the Cloud Ops API calls.
resource "terraform_data" "namespace" {
  triggers_replace = local.request

  lifecycle {
    prevent_destroy = true
  }

  provisioner "local-exec" {
    command = "python3 \"${path.module}/scripts/namespace.py\" apply"
    environment = {
      TEMPORAL_NAMESPACE_REQUEST = jsonencode(local.request)
    }
  }
}

# The read verifies the namespace and produces outputs after the create completes.
data "external" "namespace" {
  depends_on = [terraform_data.namespace]
  program    = ["python3", "${path.module}/scripts/namespace.py", "read"]
  query = {
    request = jsonencode(local.request)
  }
}
