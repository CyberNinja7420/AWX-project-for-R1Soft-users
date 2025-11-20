# CHANGELOG

## 2024-06-11
- Hardened scanner plays to ensure report directories exist, reused timestamps, and published JSON outputs as AWX artifacts.
- Added AWX/Tower compatibility shims and survey loading while keeping destroy play constrained to project-level objects.
- Improved vendor sample wrappers and idempotence checks for power-user create/disable flows.
- Added ansible.cfg defaults, refreshed Makefile targets and CI requirements, and expanded repo hygiene (.gitignore, docs).
