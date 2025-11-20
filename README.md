# sbm-user-admin

AWX/Ansible project to manage R1Soft Server Backup Manager (SBM) users across many managers.

## What this does

* Uses vendor-tested SBM API sample scripts to create/update (idempotent) and disable Power-Users (optionally Sub-Users).
* Runs from AWX with surveys and secured credentials per site/manager.
* Verifies PHP SOAP + API samples exist on each SBM before making changes.

## Prereqs

* AWX/Tower (or AAP) with a Project pointing to this repo
* Each SBM exposes API at https://<sbm>:9443 (default) and includes vendor samples in `/usr/sbin/r1soft/apisamples`
* Packages on SBM: `php-cli`, `php-soap`
* Least-privileged SBM account for automation (not `admin`)

## Quick start

1. Edit `inventories/sbms.yml` and `group_vars/sbms.yml`.
2. In AWX, create a Project to this repo, import the Inventory, and create two Job Templates:
   * **SBM – Create/Ensure Power-User** → `playbooks/sbm_user_create.yml`
   * **SBM – Disable Power-User** → `playbooks/sbm_user_disable.yml`
3. Add a Survey to each template (see `awx/surveys/*.json`).
4. Run against a non-prod SBM first.

## Importing into AWX

1. Create a **Project** pointing to this repository.
2. Create an **Inventory** and import `inventories/sbms.yml` (or sync from SCM).
3. Add **Credentials** for the SBM admin account (machine or custom type as desired).
4. Create two **Job Templates**:
   * **SBM – Create/Ensure Power-User** using `playbooks/sbm_user_create.yml` and your `sbms` inventory group.
   * **SBM – Disable Power-User** using `playbooks/sbm_user_disable.yml` and the same inventory.
5. For each Job Template, click **Add Survey** → **Import** and choose the matching file from `awx/surveys/` (`create_user.survey.json` or `disable_user.survey.json`). Save.
6. Set **Prompt on launch** for credentials to avoid storing secrets in SCM, then launch.

## Validating the playbooks before AWX

Run these checks locally (or in CI) to confirm everything needed is present and the playbooks parse correctly:

```bash
# Verify required files exist and run syntax checks when ansible-playbook is available
make self-test

# Or run syntax checks directly
make syntax-all

# Render the inventory graph to confirm the sbms group is present
make inventory-graph
```

If `ansible-playbook` is not installed, `make self-test` will still confirm that all expected repo files are present and report missing items.

## How it works

* The role copies a small PHP **wrapper** that sets variables, then includes the official vendor sample script located on the SBM host. This keeps logic vendor-validated while letting us pass parameters safely.
* Idempotence: the create wrapper checks for existing users and prints "Already exists" when no change is needed; the disable wrapper prints "Already disabled" when applicable. Ansible marks changed/ok accordingly.

## Security tips

* Use a dedicated SBM Power-User for automation; rotate creds in AWX.
* Prefer LDAP/AD for human users; keep local accounts minimal.

