ANSIBLE?=ansible-playbook
INVENTORY?=inventories/sbms.yml

syntax-create:
$(ANSIBLE) -i $(INVENTORY) playbooks/sbm_user_create.yml --syntax-check

syntax-disable:
$(ANSIBLE) -i $(INVENTORY) playbooks/sbm_user_disable.yml --syntax-check

syntax-all: syntax-create syntax-disable

inventory-graph:
ansible-inventory -i $(INVENTORY) --graph

self-test:
scripts/self_test.sh

.PHONY: syntax-create syntax-disable syntax-all inventory-graph self-test
