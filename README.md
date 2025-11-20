# sbm-user-admin

AWX/Ansible content to create/update (idempotent) and disable R1Soft Server Backup Manager (SBM) Power-Users. Two execution paths are provided:
- **Vendor samples** (default): thin wrappers around `/usr/sbin/r1soft/apisamples` for create/update and disable.
- **Pure API** fallback: SOAP envelopes via `ansible.builtin.uri` without depending on packaged samples.

## Features
- Preflight checks for HTTPS reachability, SBM version detection, PHP/SOAP packages, and sample availability.
- Idempotent outputs: wrappers emit **Already exists**, **Successfully created power user**, **Disabled**, or **Already disabled** to drive Ansible change reporting.
- Optional LDAP/AD configuration playbook.
- AWX surveys and an optional IaC bootstrap play for projects, inventory, credentials, and job templates.
- CI with `ansible-lint` and `yamllint`.
- Dry-run support (`sbm_dry_run=true`) to validate connectivity without changing users.

## Layout
- `inventories/` – example inventory for SBM endpoints.
- `group_vars/` – defaults for target user, ports, LDAP settings, and toggles.
- `playbooks/` – create/ensure, disable, and LDAP configuration entry points.
- `roles/sbm_api_samples/` – vendor-sample wrappers plus preflight tasks.
- `roles/sbm_api_direct/` – pure SOAP API fallback using `ansible.builtin.uri`.
- `awx/surveys/` – importable AWX surveys.
- `awx/bootstrap_awx.yml` – optional AWX IaC bootstrap using `awx.awx` collection.
- `docs/` – research notes, API map, test plan, and test results.
- `.github/workflows/ci.yml` – lint automation.

## Prerequisites
- AWX/Tower/AAP with access to SBM over HTTPS (default port `9443`).
- PHP with SOAP on the SBM hosts when using vendor samples (`php-cli`, `php-soap`).
- Automation credentials with least-privilege access to manage Power-Users.
- Install Python dependencies for local runs:
  ```bash
  pip install -r requirements.txt
  ```

## Configuration
- Edit `inventories/sbms.yml` with your SBM hosts.
- Update `group_vars/sbms.yml` as needed:
  - `use_vendor_samples`: default `true`; set `false` to use pure API.
  - `sbm_dry_run`: default `false`; set `true` for connectivity-only validation.
  - `sbm_target_user`: username, password (blank when LDAP), email, full_name, allow_subusers.
  - Volume placeholders (`volume_name`, `volume_path`, quotas) for vendor sample bootstrap.
  - `ldap_config` for optional LDAP/AD deployment.

## Running locally
- Preflight only:
  ```bash
  ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e sbm_dry_run=true
  ```
- Create/ensure (vendor samples):
  ```bash
  ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e use_vendor_samples=true
  ```
- Create/ensure (pure API):
  ```bash
  ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e use_vendor_samples=false
  ```
- Disable user:
  ```bash
  ansible-playbook playbooks/sbm_user_disable.yml -i inventories/sbms.yml
  ```
- Configure LDAP:
  ```bash
  ansible-playbook playbooks/sbm_ldap_config.yml -i inventories/sbms.yml -e ldap_config.enable=true
  ```

## AWX usage
1. Create a Project pointing to this repository.
2. Create an Inventory from `inventories/sbms.yml` or your source of truth.
3. Add Credentials for SBM admin access (machine or custom credential type); keep secrets out of SCM.
4. Create Job Templates:
   - **SBM – Create/Ensure Power-User** → `playbooks/sbm_user_create.yml`
   - **SBM – Disable Power-User** → `playbooks/sbm_user_disable.yml`
   - Optional **SBM – LDAP Config** → `playbooks/sbm_ldap_config.yml`
5. Import surveys from `awx/surveys/*.json` or run `awx/bootstrap_awx.yml` to create resources via the `awx.awx` collection.

## Compatibility
See `docs/research.md` for research details and the version matrix. The automation warns (but does not fail) if DCC is requested on versions older than 6.18.

## Security guidance
- Use HTTPS with trusted certificates where possible; `validate_certs` is disabled only for bootstrap convenience.
- Never hard-code secrets; rely on AWX credentials and surveys.
- Prefer LDAP/AD for human users; reserve local credentials for break-glass automation.

## CI and linting
GitHub Actions runs `yamllint` and `ansible-lint`. Locally, use:
```bash
make ci
```

## Testing
Follow `docs/test-plan.md` for acceptance steps and capture outputs in `docs/test-results.md`.

## Rollback
See `ROLLBACK.md` for user disablement, removal of vendor wrappers, toggling to pure API, and AWX cleanup.
