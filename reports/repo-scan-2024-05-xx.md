# Repository scan summary

## Scope
- Command: `SKIP_GALAXY_INSTALL=1 make lint`
- Purpose: identify lint/style gaps and missing dependencies across Ansible content.

## Key findings
1) **Missing collections in offline lint**
   - `awx.awx.*` modules (`project`, `job_template`, `inventory`) flagged as unknown because collections were not installed in offline mode.
   - `community.general.read_csv` flagged for the same reason when Galaxy dependencies are skipped.
   - Mitigation: run lint with Galaxy install enabled (requires network) or vendor needed collections locally before linting.

2) **FQCN and formatting clean-up needed**
   - `playbooks/sbm_create_reports.yml` uses short module names (`set_fact`, `fail`, `debug`, `uri`) and contains a 300+ character line and extra blank line.
   - Recommendation: convert to `ansible.builtin.*`, wrap long Jinja2 payload-building line, and trim double-blank spacing.

3) **LDAP config playbook polish**
   - `playbooks/sbm_ldap_config.yml` lacks task names on block/rescue, uses unprefixed role variable `use_vendor_samples`, and has suggested Jinja2 spacing for SOAP payload readability.

4) **Report generation tasks**
   - `playbooks/sbm_scan.yml`, `playbooks/sbm_scan_from_csv.yml`, and `playbooks/sbm_scan_report_only.yml` use `run_once` controller tasks without explicit file modes on generated reports; lint flags them as "risky-file-permissions" and warns about `run_once` semantics.
   - Recommendation: add `mode` (e.g., `0755` for directories, `0644` for files) and confirm strategy remains `linear` when using `run_once` + `delegate_to`.

5) **Role task naming/prefixing**
   - Several rescue/always blocks in `roles/sbm_api_direct` and `roles/sbm_api_samples` lack explicit `name` values, and a few registered variables (`create_out`, `disable_out`, `use_vendor_samples`) do not use the role prefix.

## Next steps
- Re-run lint with Galaxy installs allowed to confirm module availability.
- Apply FQCN/formatting clean-ups and add missing task names/variable prefixes.
- Set explicit file modes on report artifacts and verify `run_once` usage with the chosen strategy.
