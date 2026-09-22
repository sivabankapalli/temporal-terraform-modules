# Contributing

**Design rules**
- One module = one responsibility, in `modules/<name>` with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, README.
- Modules never declare `provider` or `backend` blocks; they declare `required_providers` with a minimum version only.
- Inputs are typed with validation; outputs expose IDs and names only. No environment awareness: names are inputs.
- Use `moved` blocks for renames so consumers do not destroy resources.
- Every module has `examples/<name>` (validated in CI) and a `tests/<name>.tftest.hcl` (mocked provider).

**Versioning**
- Semantic versions via git tags (`v0.1.0`). Breaking changes to inputs, outputs or resource addresses bump the major version (minor while `0.x`).
- Flow: PR -> CI green -> merge to `main` -> update `CHANGELOG.md` -> `git tag vX.Y.Z && git push --tags` -> release workflow publishes notes.
- Consumers pin exact tags; never `ref=main`.

**Consuming**
```hcl
module "project" {
  source = "git::https://<ghes-host>/<org>/temporal-tf-modules.git//modules/project?ref=v0.1.0"
}
```
