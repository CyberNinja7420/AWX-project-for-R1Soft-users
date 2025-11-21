.PHONY: all clean lint scan scan_csv bootstrap_awx syntax-check test

all: lint syntax-check

test: lint syntax-check

clean:
	rm -f reports/*.json reports/*.md *.retry
.PHONY: lint scan scan_csv bootstrap_awx syntax-check

lint:
	@if [ "${SKIP_GALAXY_INSTALL}" != "1" ]; then \
		ansible-galaxy collection install -r requirements.yml; \
	else \
		echo "Skipping ansible-galaxy collection install (SKIP_GALAXY_INSTALL=1)"; \
	fi
	@if [ "${SKIP_GALAXY_INSTALL}" = "1" ]; then \
		ansible-lint --offline; \
	else \
		ansible-lint; \
	fi
	yamllint .

scan:
	ansible-playbook playbooks/sbm_scan.yml -i inventories/sbms.yml

scan_csv:
	ansible-playbook playbooks/sbm_scan_from_csv.yml -e csv_path=data/sbms.csv

syntax-check:
	ansible-playbook playbooks/sbm_scan.yml -i inventories/sbms.yml --syntax-check
	ansible-playbook playbooks/sbm_scan_from_csv.yml -e csv_path=data/sbms.csv --syntax-check

bootstrap_awx:
	ansible-galaxy collection install -r requirements.yml
	ansible-playbook awx/bootstrap_awx.yml -e awx_host=$AWX_HOST -e awx_token=$AWX_TOKEN -e project_repo_url=$REPO_URL
