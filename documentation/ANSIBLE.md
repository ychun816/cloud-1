# Ansible

## repo structure
```
.
├── ANSIBLE.md                  
├── ansible.cfg                 # Global settings (overrides defaults, points to roles/inventory).
├── group_vars                  # Folder for variables shared across groups of servers.
│   └── all.yml                 # Variables that apply to EVERY server (e.g., global timezone).
├── variables.yml               # Centralized project-specific variables (paths, git repo urls).
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


# **Variable Management: Why use `variables.yml`?**

In simple projects, it's tempting to put variables directly into `playbook.yml`. However, professional DevOps standardizes on separating **Code** (Playbooks) from **Configuration** (Variables).

1.  **Reusability:** The same playbook can run on Dev, Staging, and Prod just by swapping the variable file.
2.  **Scope:** Variables defined in `variables.yml` and imported via `vars_files` are globally available to **all roles**, whereas task-level vars are often restricted.
3.  **Clarity:** Developers can see *what* is being deployed (paths, versions) without wading through *how* it is deployed.

**Example in this project:**
We use `ansible/variables.yml` to define:
*   `app_dir`: Where the app lives (`/opt/cloud-1`).
*   `compose_dir`: Where the docker-compose file lives.

This prevents hardcoding paths inside roles like `roles/docker/tasks/main.yml`.


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

---

## ansible set-up

* install ansible
```bash
sudo apt-get update && sudo apt-get install -y ansible
```


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

* Analogy: 
- Ansible: The Organizer.
- Playbook: The To-Do List (Install Nginx, Start Docker).
- ansible.cfg: The "Company Policy" or "Rulebook".

> WHY need `export` first?
> Ansible looks for its configuration file in a specific priority order : (1) ./ansible.cfg (Current Directory) -> (2) ~/.ansible.cfg (Home Directory) -> (3) /etc/ansible/ansible.cfg (Global System Default)
> run `export` as "Safety Lock" even already in the home repo: 
> 1. Protection against "Current Directory" confusion -> `export` ensures that no matter where you stand in the terminal, Ansible uses the correct file.
> 2. Disabling Host Key Checking -> local development environments (like Vagrant or local VMs) change their "fingerprints" frequently. The local ansible.cfg prob has `host_key_checking = False`. If Ansible misses this file and uses the global default (which is True), the connection will fail immediately with an SSH error


3. Run the Deployment (Manual Action Required)
```bash
ansible-playbook -i inventories/local/hosts.ini playbook.yml
```

--

## notes during run anisible playbook 

- `apt` installs packages for Ubuntu (Linux).
- `brew` installs packages for macOS.
- `npm` installs packages for JavaScript/Node.js.
- `pip` installs packages (libraries) written in Python.

---

## Troubleshooting Summary: Common Automization Errors

Transition from **Manual Execution** to **Automated Deployment**

| Error Category | Symptom / Log Message | Root Cause | Fix Applied |
| :--- | :--- | :--- | :--- |
| **Environment Variables** | `docker compose` fails silently or containers crash on start. | Manual shell run has `$USER/_vars` loaded; Systemd runs in empty env. | Added `Environment="DATA_DIR={{ app_dir }}/data"` to systemd service unit. |
| **Systemd Timing** | `Warning: The unit file changed on disk.` | Ansible notifies handlers strictly at end-of-play; next task tried to start stale service. | Added `meta: flush_handlers` to force daemon-reload immediately after file creation. |
| **Missing Directories** | `CHDIR failed: No such file or directory` (Systemd status). | Variable `{{ compose_dir }}` was undefined, so Ansible created nothing or wrong path. | Centralized `app_dir` and `compose_dir` in `variables.yml` to ensure role visibility. |
| **Volume Paths** | Docker creates internal volumes instead of using host folders. | `docker-compose.yml` used named volumes without `device` bindings for `DATA_DIR`. | Updated compose file to explicitly bind mount host paths using `${DATA_DIR}`. |
| **CI Visibility** | "Task Failed" with no useful output in GitHub Actions. | CI runner is non-interactive; standard error logs aren't always captured by Ansible. | Added `block/rescue` logic to run `journalctl -xe` and print logs upon failure. |


---

## ansible testing commands (to do!)

```bash
ansible-galaxy init role_test
mkdir -p [repo_name]
ansible-galaxy init test
ansible-galaxy lint
ansible-galaxy role
ansible validate

```

---


## Ansible Implementation

> other notes in /anible/README.md

### Ansible files & workflow:
1. `inventory.ini` tells Ansible where to connect.
2. `playbook.yml` defines what to do.
3. `variables.yml` defines values used by the playbook.
4. `.j2` templates are rendered with those variables and written to the target server.
5. The result → Docker app deployed on your EC2. 
```
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

### files brief
```bash
| Path                                           | Type            | Purpose                                                                                                | Example Usage                                           |
| ---------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| `inventory.ini`                                | File            | Lists your **target servers** (where Ansible will deploy). Defines host groups (`[web]`, `[db]`, etc.) | Defines EC2 instance IP, SSH key path                   |
| `inventory.ini.example`                        | Template        | Example version of `inventory.ini` for reference or new users                                          | Shows how to structure connection settings              |
| `playbook.yml`                                 | File            | The **main Ansible script** — defines what tasks or roles to run on which host groups                  | Calls the `docker` role to deploy your app              |
| `roles/docker/`                                | Folder          | Self-contained logic for configuring Docker                                                            | Reusable building block                                 |
| `roles/docker/tasks/main.yml`                  | File            | Contains a **sequence of tasks** (Ansible actions)                                                     | Install Docker, copy compose template, start containers |
| `roles/docker/templates/docker-compose.yml.j2` | Jinja2 template | Template for Docker Compose file                                                                       | Variables in `{{ brackets }}` get replaced              |
| `variables.yml`                                | File            | Stores global **variables** used in playbook and templates                                             | Defines repo URL, app directory, etc.                   |
```