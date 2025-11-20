ANSIBLE ?= ansible-playbook
INVENTORY ?= inventories/sbms.yml

syntax-create:
	$(ANSIBLE) -i $(INVENTORY) playbooks/sbm_user_create.yml --syntax-check

syntax-disable:
	$(ANSIBLE) -i $(INVENTORY) playbooks/sbm_user_disable.yml --syntax-check

syntax-ldap:
	$(ANSIBLE) -i $(INVENTORY) playbooks/sbm_ldap_config.yml --syntax-check

syntax-all: syntax-create syntax-disable syntax-ldap

lint:
	ansible-lint || true

yamlcheck:
	yamllint .

inventory-graph:
	ansible-inventory -i $(INVENTORY) --graph

self-test:
	scripts/self_test.sh

ci: lint yamlcheck syntax-all
	
.PHONY: syntax-create syntax-disable syntax-ldap syntax-all lint yamlcheck inventory-graph self-test ci
