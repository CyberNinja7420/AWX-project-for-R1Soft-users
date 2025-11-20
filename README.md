# sbm-user-admin

AWX/Ansible content to scan Server Backup Manager (SBM) inventories, render reports, and manage Power-Users through vendor samples or pure API fallbacks. Scanner playbooks can run directly against inventory hosts or CSV-provided endpoints, and AWX IaC plays wire projects, inventories, job templates, and surveys.

## Scanner & Reports
- Role `roles/sbm_scan/` performs HTTP reachability, API/survey auth probing, best-effort version guessing, and optional SSH checks for vendor samples and PHP SOAP availability.
- Playbooks:
  - `playbooks/sbm_scan.yml` (Path A): scan hosts already present in the `sbms` group.
  - `playbooks/sbm_scan_from_csv.yml` (Path B): build an in-memory `sbms` group from CSV, then scan.
  - `playbooks/sbm_scan_report_only.yml`: regenerate JSON/Markdown reports from existing host vars (useful for AWX artifacts).
- Reports render to `reports/` as `sbm_scan_<UTC>.json` and `.md` using templates in `roles/sbm_scan/templates/`.

## CSV Onboarding
- Sample `data/sbms.csv` demonstrates the header `name,host,port,site,env,api_user,api_pass_var,dcc_url` with placeholder rows.
- `playbooks/sbm_scan_from_csv.yml` reads the CSV and builds in-memory inventory; `awx/onboard_sbms_from_csv.yml` can mirror the CSV into an AWX inventory.
- Keep secrets (API passwords) out of CSV; reference AWX/Vault variables (e.g., `api_pass_var`) instead.

## AWX Bootstrap (IaC)
- `awx/bootstrap_awx.yml` ensures the Project (pointed at this repo), Inventory `R1Soft-SBMs`, placeholder credential, and Job Templates with surveys:
  - "SBM – Inventory Scan & Report (Inventory)" → `playbooks/sbm_scan.yml`
  - "SBM – Inventory Scan & Report (CSV)" → `playbooks/sbm_scan_from_csv.yml`
  - "SBM – Create/Ensure Power-User" → `playbooks/sbm_user_create.yml`
  - "SBM – Disable Power-User" → `playbooks/sbm_user_disable.yml`
- Surveys live in `awx/surveys/`; scanner survey accepts optional defaults for API credentials and CSV path.
- `awx/onboard_sbms_from_csv.yml` syncs CSV rows into the AWX inventory, and `awx/destroy_awx_objects.yml` removes the project/inventory/job templates if rollback is needed.

## Power-User management
- Vendor sample wrappers (`roles/sbm_api_samples/`) and pure SOAP API fallback (`roles/sbm_api_direct/`) remain available for creating/updating or disabling SBM Power-Users.
- Behavior toggles and defaults live in `group_vars/sbms.yml`; inventories are defined under `inventories/`.

## Quick Start
- Local Path A (inventory):
  ```bash
  ansible-playbook playbooks/sbm_scan.yml -i inventories/sbms.yml -e api_user=$SBM_USER -e api_pass=$SBM_PASS
  ```
- Local Path B (CSV):
  ```bash
  ansible-playbook playbooks/sbm_scan_from_csv.yml -e csv_path=data/sbms.csv -e api_user=$SBM_USER -e api_pass=$SBM_PASS
  ```
- AWX Bootstrap (IaC):
  ```bash
  ansible-galaxy collection install -r requirements.yml
  ansible-playbook awx/bootstrap_awx.yml -e awx_host=https://awx.example -e awx_token=REPLACE -e project_repo_url=REPO_URL
  ```
- Power-User flows (vendor samples):
  ```bash
  ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e use_vendor_samples=true
  ansible-playbook playbooks/sbm_user_disable.yml -i inventories/sbms.yml
  ```

## Security notes
- Provide secrets via AWX Credentials or survey answers (masked); do not commit credentials to Git or store plaintext secrets in CSV.
- HTTPS certificate validation is disabled in probes/bootstraps for compatibility; prefer trusted certs in production.
- Keep Vault variables or AWX credential injection for API passwords referenced by `api_pass_var` in CSV rows.

## Layout
- `inventories/` – example inventory for SBM endpoints.
- `group_vars/` – defaults for target users, ports, LDAP settings, and scanner defaults.
- `playbooks/` – scanner entry points plus user create/disable and LDAP configuration.
- `roles/sbm_scan/` – scanner tasks and report templates.
- `roles/sbm_api_samples/` / `roles/sbm_api_direct/` – Power-User automation implementations.
- `awx/` – surveys and AWX IaC plays (bootstrap, onboarding from CSV, destroy).
- `docs/` – research notes, test plans, and results.
- `.github/workflows/ci.yml` – lint automation.

## CI and linting
GitHub Actions runs `make lint` (yamllint + ansible-lint). Locally:
```bash
make lint
```

## Testing
Follow `docs/test-plan-scan.md` for scanner acceptance steps and `docs/test-plan.md` for Power-User coverage.

## Rollback
Use `awx/destroy_awx_objects.yml` to remove AWX objects or see `ROLLBACK.md` for additional user-level cleanup paths.
