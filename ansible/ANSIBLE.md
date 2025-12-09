# Ansible

This folder follows a concise, environment-oriented layout that’s common practice.

## Repository layout

```text
ansible/
├── ansible.cfg
├── inventories/
│   ├── local/hosts.ini
│   ├── dev/hosts.ini
│   └── prod/hosts.ini
├── playbooks/
│   ├── setup_tools.yml      # installs Terraform & AWS CLI locally (macOS)
│   └── docker_deploy.yml    # deploys the Docker Compose stack to hosts in [web]
├── group_vars/
│   └── all.yml              # global defaults (repo_url, app_dir, compose_dir)
├── roles/
│   ├── terraform/
│   ├── awscli/
│   └── docker/
├── files/
├── templates/
└── ANSIBLE.md
```

## How to run

- Install collections (recommended):

```bash
ansible-galaxy collection install community.general
```

- Setup local tools (macOS):

```bash
ansible-playbook -i inventories/local/hosts.ini playbooks/setup_tools.yml
```

- Deploy Docker stack (to dev/prod):

```bash
ansible-playbook -i inventories/dev/hosts.ini playbooks/docker_deploy.yml
# or
ansible-playbook -i inventories/prod/hosts.ini playbooks/docker_deploy.yml
```

## Notes

- Use `group_vars/all.yml` for shared variables. Add `group_vars/dev.yml` or `group_vars/prod.yml` later if environment-specific differences grow.
- Keep roles focused and reusable. `docker` role handles host setup and compose; `terraform` and `awscli` roles handle local tooling.
- For linting or CI, consider `ansible-lint` and a `collections/requirements.yml` to pin exact collection versions.

