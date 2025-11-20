# Test results

Document the executed runs here, including inventory target, timestamp, command, and key output excerpts.

| Date | Target | Path (vendor / direct) | Command | Result |
| --- | --- | --- | --- | --- |
| _pending_ | _non-prod SBM_ | vendor | `ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e sbm_dry_run=true` | _pending_ |
| _pending_ | _non-prod SBM_ | vendor | `ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e sbm_target_user.username=test_poweruser` | _pending_ |
| _pending_ | _non-prod SBM_ | vendor | `ansible-playbook playbooks/sbm_user_disable.yml -i inventories/sbms.yml -e sbm_target_user.username=test_poweruser` | _pending_ |
| _pending_ | _non-prod SBM_ | direct | `ansible-playbook playbooks/sbm_user_create.yml -i inventories/sbms.yml -e use_vendor_samples=false -e sbm_target_user.username=test_poweruser_api` | _pending_ |
| _pending_ | _non-prod SBM_ | direct | `ansible-playbook playbooks/sbm_user_disable.yml -i inventories/sbms.yml -e use_vendor_samples=false -e sbm_target_user.username=test_poweruser_api` | _pending_ |
