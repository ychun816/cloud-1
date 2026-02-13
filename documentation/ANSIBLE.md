# Ansible

## repo structure

- Use `group_vars/all.yml` for shared variables. Add `group_vars/dev.yml` or `group_vars/prod.yml` later if environment-specific differences grow.
- Keep roles focused and reusable. `docker` role handles host setup and compose; `terraform` and `awscli` roles handle local tooling.
- For linting or CI, consider `ansible-lint` and a `collections/requirements.yml` to pin exact collection versions.


```bash
cloud-1/ansible/
├── ansible.cfg
├── group_vars
│   └── all.yml
├── inventories
│   ├── dev
│   │   └── hosts.ini
│   ├── local
│   │   └── hosts.ini
│   └── prod
│       └── hosts.ini
├── playbook.yml
├── playbooks
│   ├── docker_deploy.yml
│   └── setup_tools.yml
├── roles
│   ├── awscli
│   │   └── tasks
│   │       └── main.yml
│   ├── cloudwatch
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── amazon-cloudwatch-agent.json.j2
│   ├── docker
│   │   └── tasks
│   │       └── main.yml
│   └── terraform
│       └── tasks
│           └── main.yml
├── scripts
│   └── generate_inventory.py
├── tools.yml
└── variables.yml
```

| Folder   | Use case                                                      |
| -------- | ------------------------------------------------------------- |
| `local/` | laptop (installing terraform, docker, testing playbooks)      |
| `dev/`   | Development servers in cloud or on-prem                       |
| `prod/`  | Production servers with strict control                        |


| Directory        | Purpose                                            |
| ---------------- | -------------------------------------------------- |
| **ansible.cfg**  | Central configuration for Ansible behavior.        |
| **inventories/** | Clean separation of local/dev/prod servers.        |
| **group_vars/**  | Central shared variables; automatically loaded.    |
| **files/**       | Static files copied exactly as stored.             |
| **templates/**   | Jinja2 files rendered dynamically per environment. |

---

## workflow
1. `inventory.ini` tells Ansible where to connect.
2. `playbook.yml` defines what to do.
3. `variables.yml` defines values used by the playbook.
4. `.j2` templates are rendered with those variables and written to the target server.
5. The result → Docker app deployed on your EC2. 

```bash
TEMPLATE (.j2)
↓ + VARIABLES
-------------------
= RENDERED FILE (.yml)
↓
→ COPIED TO SERVER
↓
→ USED IN DEPLOYMENT
```

```bash
┌──────────────────────────────┐
│        YOU (the user)        │
│ Run: ansible-playbook playbook.yml
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ inventory.ini                │
│ - Defines target hosts, SSH  │
│   keys, interpreter, etc.    │
│ Example: 1.2.3.4 ansible_user=ubuntu
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ playbook.yml                 │
│ - Calls "roles/docker"       │
│ - Includes "variables.yml"   │
│ - Tells Ansible to apply     │
│   the template task          │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ variables.yml                │
│ - Defines values used inside │
│   the Jinja2 template        │
│ e.g. app_dir=/opt/cloud-1    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ roles/docker/tasks/main.yml  │
│ - Has a task like:           │
│   template:                  │
│     src: docker-compose.yml.j2
│     dest: "{{ compose_dir }}/docker-compose.yml"
└──────────────┬───────────────┘
               │
               ▼
────────────────────────────────────────────
   Inside the `template:` task (Ansible magic)
────────────────────────────────────────────
               │
               ▼
┌──────────────────────────────┐
│ 1️⃣ Read Source Template (.j2) │
│ e.g., roles/docker/templates/ │
│      docker-compose.yml.j2    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 2️⃣ Parse with Jinja2 Engine  │
│ - Finds {{ variables }} and  │
│   {% logic %} blocks         │
│ - Replaces using vars.yml or │
│   playbook vars              │
│ Example:                     │
│   "{{ app_dir }}" → "/opt/cloud-1"
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 3️⃣ Render Final Text File    │
│ - The template now becomes a │
│   plain YAML file (no braces)│
│ Example output:              │
│   volumes:                   │
│     - /opt/cloud-1/html:/usr/share/nginx/html
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 4️⃣ Copy Rendered File to     │
│   Remote Host via SSH        │
│ - Saved at path in 'dest:'   │
│   e.g. /opt/cloud-1/compose/ │
│        docker-compose.yml    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ 5️⃣ Next Task Executes Docker │
│   - "docker compose up -d"   │
│   - Containers start running │
│     using the rendered file  │
└──────────────────────────────┘
```

---


## Key Ansible Files and Directories

| File/Directory   | Purpose/Explanation                                                                 |
|------------------|-------------------------------------------------------------------------------------|
| playbook.yml     | Main entry point: defines tasks and roles to run for deployment/configuration.      |
| tools.yml        | Playbook for setting up local tools (e.g., Terraform, AWS CLI) on your machine.     |
| variables.yml    | Central file for variables used across playbooks and roles.                         |
| group_vars/      | Stores variables for groups of hosts (e.g., dev, prod); enables environment-specific or shared settings. |
| inventories/     | Contains inventory files (hosts.ini) for each environment (dev, prod, local); lists servers Ansible manages. |
| playbooks/       | Holds reusable playbook files for different tasks (e.g., docker_deploy.yml).        |
| roles/           | Modular, reusable components for specific functions (e.g., docker, terraform, awscli). |
| scripts/         | Helper scripts (e.g., generate_inventory.py) for automating inventory or other tasks. |

--- 

## Terraform -> Ansible -> Docker

- **Terraform**: Automated, dynamic tool for provisioning infrastructure (servers, networks, etc.). It creates the "space" and "engines" (VMs, networks) but does not initialize them.
- **Ansible**: Automated, dynamic tool for configuring and initializing servers after Terraform creates them. It installs dependencies, sets up users, configures security, and deploys applications. Ansible acts as the orchestrator for Docker and other services.
- **Docker (Dockerfile/docker-compose.yml)**: Static blueprints for building and running application containers. These files define how your apps run, but do not change unless you edit them. Ansible copies and launches these on the servers.

**Workflow summary:**
1. Terraform provisions infrastructure (dynamic, automated)
2. Ansible configures and deploys (dynamic, automated)
3. Dockerfiles/compose define the static application setup, which Ansible deploys and runs

> This separation ensures infrastructure is created, prepared, and then applications are reliably deployed and managed.


| Tool       | What it Does (Explanation)                                      | Analogy (from your description)                |
|------------|-----------------------------------------------------------------|------------------------------------------------|
| Terraform  | Provisions infrastructure: creates servers, networks, etc.      | Builds the rooms and engines (space, structure) |
| Ansible    | Configures and deploys: installs dependencies, sets up servers, | Furnishes and powers up the rooms (init, setup) |
|            | and launches applications (orchestrates Docker)                 |                                                |
| Docker     | Defines and runs application containers (Dockerfile/Compose)    | The blueprints and furniture for each room      |


> Terraform = Automated, dynamic infrastructure builder
> Ansible = Automated, dynamic server initializer and application deployer
> Docker = Static application definition, launched by Ansible

---


## test commands

### Install collections

```bash

# install ansible
sudo apt-get update && sudo apt-get install -y ansible

ansible-galaxy collection install community.general

# Setup local tools (macOS):
ansible-playbook -i inventories/local/hosts.ini playbooks/setup_tools.yml

# Deploy Docker stack (to dev/prod):
ansible-playbook -i inventories/dev/hosts.ini playbooks/docker_deploy.yml
# or
ansible-playbook -i inventories/prod/hosts.ini playbooks/docker_deploy.yml
```

---

## ansible set-up

1. Verify Syntax
```bash
ansible-playbook -i inventories/local/hosts.ini playbook.yml --syntax-check
```

2. Run the Playbook (Dry Run)
```bash
export ANSIBLE_CONFIG=$(pwd)/ansible.cfg # 
ansible-playbook -i inventories/local/hosts.ini playbook.yml --check
```
When run the command above, Ansible will:
1. Bootstrap: Install system tools (curl, gnupg, ufw).
2. Install Docker: Set up the official Docker repository and install the engine.
3. Setup App: Clone cloud-1 repository to /opt/cloud-1.
4. Systemd: Create a startup
>  run this once per terminal session, run multiple times until it's right 
> WHY need `export` first?
> Ansible looks for its configuration file in a specific priority order : (1) ./ansible.cfg (Current Directory) -> (2) ~/.ansible.cfg (Home Directory) -> (3) /etc/ansible/ansible.cfg (Global System Default)
> run `export` as "Safety Lock" even already in the home repo: 
> 1. Protection against "Current Directory" confusion -> `export` ensures that no matter where you stand in the terminal, Ansible uses the correct file.
> 2. Disabling Host Key Checking -> local development environments (like Vagrant or local VMs) change their "fingerprints" frequently. The local ansible.cfg prob has `host_key_checking = False`. If Ansible misses this file and uses the global default (which is True), the connection will fail immediately with an SSH error


3. Run the Deployment (Manual Action Required)
```bash
ansible-playbook -i inventories/local/hosts.ini playbook.yml
```


---

## Common Automization Errors

Transition from **Manual Execution** to **Automated Deployment**

| Error Category | Symptom / Log Message | Root Cause | Fix Applied |
| :--- | :--- | :--- | :--- |
| **Environment Variables** | `docker compose` fails silently or containers crash on start. | Manual shell run has `$USER/_vars` loaded; Systemd runs in empty env. | Added `Environment="DATA_DIR={{ app_dir }}/data"` to systemd service unit. |
| **Systemd Timing** | `Warning: The unit file changed on disk.` | Ansible notifies handlers strictly at end-of-play; next task tried to start stale service. | Added `meta: flush_handlers` to force daemon-reload immediately after file creation. |
| **Missing Directories** | `CHDIR failed: No such file or directory` (Systemd status). | Variable `{{ compose_dir }}` was undefined, so Ansible created nothing or wrong path. | Centralized `app_dir` and `compose_dir` in `variables.yml` to ensure role visibility. |
| **Volume Paths** | Docker creates internal volumes instead of using host folders. | `docker-compose.yml` used named volumes without `device` bindings for `DATA_DIR`. | Updated compose file to explicitly bind mount host paths using `${DATA_DIR}`. |
| **CI Visibility** | "Task Failed" with no useful output in GitHub Actions. | CI runner is non-interactive; standard error logs aren't always captured by Ansible. | Added `block/rescue` logic to run `journalctl -xe` and print logs upon failure. |


---

## ansible testing commands

```bash
# Create a new Ansible role scaffold named 'role_test'
ansible-galaxy init role_test

# Create a new directory (replace [repo_name] with your folder name)
mkdir -p [repo_name]

# Create another Ansible role scaffold named 'test'
ansible-galaxy init test

# Lint (check) all roles in the current directory for best practices
ansible-galaxy lint

# List installed Ansible Galaxy roles
ansible-galaxy role

# Validate your Ansible playbook or role syntax
ansible validate
```