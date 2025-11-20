.PHONY: lint scan scan_csv bootstrap_awx
lint:
	@ansible-lint || true
	@yamllint .
scan:
	ansible-playbook playbooks/sbm_scan.yml -i inventories/sbms.yml
scan_csv:
	ansible-playbook playbooks/sbm_scan_from_csv.yml -e csv_path=data/sbms.csv
bootstrap_awx:
	ansible-galaxy collection install -r requirements.yml
	ansible-playbook awx/bootstrap_awx.yml -e awx_host=$AWX_HOST -e awx_token=$AWX_TOKEN -e project_repo_url=$REPO_URL
