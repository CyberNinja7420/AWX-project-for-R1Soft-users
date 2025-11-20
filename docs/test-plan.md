# Test plan

## Connectivity & preflight
1. Run `ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e sbm_dry_run=true`.
2. Expect: HTTPS reachable, version detected, warnings for deprecated DCC if requested, and vendor sample/path validation. No changes reported.

## Create user – vendor samples
1. Execute `ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e use_vendor_samples=true -e sbm_target_user.username=test_poweruser`.
2. Expect: `changed=1` with output containing `Successfully created power user`.
3. Re-run with the same parameters to confirm idempotence. Expect `changed=0` and `Already exists` in output.

## Disable user – vendor samples
1. Execute `ansible-playbook playbooks/sbm_user_disable.yml -i inventories/sbms.yml -e use_vendor_samples=true -e sbm_target_user.username=test_poweruser`.
2. Expect: `changed=1` with output containing `Disabled`.
3. Re-run to confirm idempotence. Expect `changed=0` with `Already disabled` or `no user found` messaging.

## Pure API fallback
1. Execute `ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e use_vendor_samples=false -e sbm_target_user.username=test_poweruser_api`.
2. Expect identical results/messages to the vendor-sample path.
3. Run the disable flow with `use_vendor_samples=false` and confirm the same output conventions.

## LDAP mode
1. Configure LDAP using `ansible-playbook playbooks/sbm_ldap_config.yml -i inventories/sbms.yml -e ldap_config.enable=true` with representative values.
2. Create a user without a local password and validate login through an LDAP test account.

## CI/lint
1. Run `yamllint .` and `ansible-lint` locally or in GitHub Actions.
2. Ensure playbooks and roles pass syntax checks via `make syntax-all`.
