# temporal-tf-modules

Reusable Terraform modules for Temporal Cloud, consumed by `temporal-account-provisioning` (and any team that needs them) through version-pinned git sources. Requires provider `temporalio/temporalcloud >= 1.9.0`.

| Module | Wraps | Since |
|---|---|---|
| `modules/project` | `temporalcloud_project` | v0.1.0 |
| `modules/custom-role` | `temporalcloud_custom_role` | v0.2.0 |
| `modules/service-account` | `temporalcloud_service_account` | v0.2.0 |
| `modules/group-access` | `temporalcloud_group_access` | v0.2.0 |
| `modules/project-access` | composite: admin role + admin service account + admin group access, scoped to one project | v0.2.0 |

`project-access` is a workaround: `group_access` and `service_account` have no native project-level access yet (tracked upstream). It substitutes an account-level custom role scoped to the one project via `resource_type = "projects"`. Swap it out once the provider supports `project_accesses` directly.

## Use a module

```hcl
module "project" {
  source = "git::https://<ghes-host>/<org>/temporal-tf-modules.git//modules/project?ref=v0.1.0"

  display_name = "payments"
  description  = "Payments team project."
}
```

## Layout

```
modules/<name>/    the module
examples/<name>/   runnable example, validated in CI
tests/             terraform test files (mocked provider, no credentials needed)
docs/CONTRIBUTING.md   design rules and release process
```

## Release

Merge to `main`, update `CHANGELOG.md`, then `git tag v0.1.0 && git push origin v0.1.0`. See `docs/CONTRIBUTING.md`.
