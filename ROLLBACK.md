# Rollback guide

## Disable or delete users
- To **disable** a Power-User (idempotent):
  ```bash
  ansible-playbook playbooks/sbm_user_disable.yml -i inventories/sbms.yml -e sbm_target_user.username=<user>
  ```
- To **remove** a user entirely, disable first, then remove related volumes/sub-users manually per site policy.

## Remove vendor wrappers
- Delete the wrapper scripts on each SBM host (default paths):
  ```bash
  rm -f /root/awx-sbm-create-power-user.php /root/awx-sbm-disable-power-user.php
  ```
- Re-run with `use_vendor_samples=false` to exercise the pure-API path and avoid reliance on packaged samples.

## Toggle to pure-API mode
- Set `use_vendor_samples=false` (via AWX survey or extra var) to switch to `roles/sbm_api_direct` without removing other artifacts.
- Use `sbm_dry_run=true` to validate connectivity and version checks without changing users.

## Clean up AWX objects (IaC)
- If created via `awx/bootstrap_awx.yml`, remove using the same play with `state=absent` overrides:
  ```bash
  ansible-playbook awx/bootstrap_awx.yml -e awx_state=absent -e awx_host=https://awx.example -e awx_token=<token>
  ```
- Alternatively, delete Project, Inventory, Credentials, and Job Templates from the AWX GUI.

## Git/SCM rollback
- Revert the repo to a known good state:
  ```bash
  git reset --hard <previous_revision>
  git clean -fd
  ```
- Restore prior release tag or branch as required.
