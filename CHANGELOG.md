# Changelog

## v0.2.0
- Add `modules/custom-role` (wraps `temporalcloud_custom_role`).
- Add `modules/service-account` (wraps `temporalcloud_service_account`).
- Add `modules/group-access` (wraps `temporalcloud_group_access`).
- Add `modules/project-access` (composite: project-scoped admin role + admin service account + admin group access). Workaround until the provider supports project-level access natively.

## v0.1.0
- Add `modules/project` (wraps `temporalcloud_project`).
