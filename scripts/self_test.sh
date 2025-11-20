#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  "playbooks/sbm_user_create.yml"
  "playbooks/sbm_user_disable.yml"
  "playbooks/sbm_ldap_config.yml"
  "roles/sbm_api_samples/tasks/preflight.yml"
  "roles/sbm_api_samples/tasks/ensure_power_user.yml"
  "roles/sbm_api_samples/tasks/disable_power_user.yml"
  "roles/sbm_api_samples/templates/wrappers/create_power_user_wrapper.php.j2"
  "roles/sbm_api_samples/templates/wrappers/disable_power_user_wrapper.php.j2"
  "roles/sbm_api_direct/tasks/ensure_user.yml"
  "roles/sbm_api_direct/tasks/disable_user.yml"
  "awx/surveys/create_user.survey.json"
  "awx/surveys/disable_user.survey.json"
  "inventories/sbms.yml"
  "group_vars/sbms.yml"
)

missing=()
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    missing+=("$file")
  fi
done

if (( ${#missing[@]} )); then
  echo "Missing files:" >&2
  printf ' - %s\n' "${missing[@]}" >&2
  exit 1
fi

echo "All expected files present."

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook is not installed; skipping syntax checks." >&2
  exit 0
fi

ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY:-inventories/sbms.yml}"

ansible-playbook -i "$ANSIBLE_INVENTORY" playbooks/sbm_user_create.yml --syntax-check
ansible-playbook -i "$ANSIBLE_INVENTORY" playbooks/sbm_user_disable.yml --syntax-check
ansible-playbook -i "$ANSIBLE_INVENTORY" playbooks/sbm_ldap_config.yml --syntax-check

if command -v ansible-inventory >/dev/null 2>&1; then
  ansible-inventory -i "$ANSIBLE_INVENTORY" --graph
fi
