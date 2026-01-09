# Ansible

## repo structure
```
.
├── ANSIBLE.md                  
├── ansible.cfg                 # Global settings (overrides defaults, points to roles/inventory).
├── group_vars                  # Folder for variables shared across groups of servers.
│   └── all.yml                 # Variables that apply to EVERY server (e.g., global timezone).
├── inventories                 # Your "Address Books" (lists of IP addresses), organized by env.
│   ├── dev
│   │   └── hosts.ini           # List of Development servers/IPs.
│   ├── local
│   │   └── hosts.ini           # Configuration to target local machine (localhost).
│   └── prod
│       └── hosts.ini           # List of Production servers/IPs (Be careful here!).
├── playbook.yml                # The "Master Plan" playbook (likely runs everything).
├── playbooks                   # Folder for smaller, specific-use playbooks.
│   ├── docker_deploy.yml       # A specific play to deploy containers (not just install Docker).
│   └── setup_tools.yml         # A specific play to install utility tools.
├── roles                       # Reusable "Skills" (packages) you can teach a server.
│   ├── awscli
│   │   └── tasks
│   │       └── main.yml        # The actual recipe steps to install AWS CLI.
│   ├── docker
│   │   └── tasks
│   │       └── main.yml        # The actual recipe steps to install Docker Engine.
│   └── terraform
│       └── tasks
│           └── main.yml        # The actual recipe steps to install Terraform.
└── tools.yml                   # A root-level playbook specifically for running the tool roles.
```

-  ** `ansible.cfg` :**

        - This file defines the **default behavior** of Ansible for the project.
        - It is the *central configuration* file.
        - It ensures **consistent behavior for all teammates**, without requiring long command-line flags.

        - Typical settings include:

        * default inventory path
        * SSH settings
        * privileges (become)
        * roles search paths
        * retry files
        * callback plugins
        * stdout formatting


- ** `Inventories` :**
Cleanly separate **environment configurations**.

```
inventories/
├── local/
│   └── hosts.ini
├── dev/
│   └── hosts.ini
└── prod/
    └── hosts.ini
```


        - Each folder = one environment: 

| Folder   | Use case                                                      |
| -------- | ------------------------------------------------------------- |
| `local/` | Your laptop (installing terraform, docker, testing playbooks) |
| `dev/`   | Development servers in cloud or on-prem                       |
| `prod/`  | Production servers with strict control                        |
> * prevents mixing dev/prod variables
> * avoids accidental deployment to prod
> * mirrors Terraform/Kubernetes environment separation
> * simplifies CI/CD pipelines
> * scales when environments grow

- **How the environment is selected**

You run:

```bash
ansible-playbook -i inventories/dev/hosts.ini playbooks/setup_tools.yml
```

> This points Ansible to the correct set of target machines.


- **`group_vars` exists**
This is the standard place to put **variables shared across multiple hosts or roles**.

```
group_vars/
└── all.yml
```

        - Purpose: 

        * avoid duplicating variables in playbooks
        * keep configuration in a single location
        * override settings per environment if needed
        * provide defaults for all hosts

### **`group_vars/all.yml` :**

Automatically loaded for **every inventory** and **every playbook**.
No need to import it manually.
If you have dev/prod differences, create:
```
group_vars/dev.yml
group_vars/prod.yml
```
> Ansible automatically selects the correct file based on your inventory’s group names.


# **Purpose of `files/`**
This folder stores **static files** that Ansible must copy to a target machine, without modification.

        - Examples:

        * certificates
        * static config files
        * binaries
        * service files
        * shell scripts

        - Usage example:

        ```yaml
        - name: Copy service file
        copy:
        src: files/myservice.service
        dest: /etc/systemd/system/myservice.service
        ```

        - When to use `files/` :
        When you need to deliver a file *exactly as it is*.


- **`templates/` :**

This folder stores **Jinja2 template files**, which Ansible renders dynamically before copying.

These files can contain variables:

`docker-compose.yml.j2`:

```yaml
version: "3"
services:
  app:
    image: "{{ docker_image }}"
    ports:
      - "{{ app_port }}:80"
```

Usage example:

```yaml
- name: Deploy docker compose from template
  template:
    src: templates/docker-compose.yml.j2
    dest: /opt/app/docker-compose.yml
```

        - **Why templates are essential**

        They allow environment-dependent generation of config files:
        * dev gets dev configs
        * prod gets hardened/secure configs
        * one template deploys many variations


| Directory        | Purpose                                            |
| ---------------- | -------------------------------------------------- |
| **ansible.cfg**  | Central configuration for Ansible behavior.        |
| **inventories/** | Clean separation of local/dev/prod servers.        |
| **group_vars/**  | Central shared variables; automatically loaded.    |
| **files/**       | Static files copied exactly as stored.             |
| **templates/**   | Jinja2 files rendered dynamically per environment. |


---


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

