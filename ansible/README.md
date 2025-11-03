# Ansible

## repo structure 

```yaml
📁 ansible/
│
├── inventory.ini                     # Defines your target hosts (e.g., web, db)
│
├── playbook.yml                      # MAIN PLAYBOOK ENTRY POINT
│   │
│   ├── 🟩 Play 1: "Deploy cloud-1 compose stack"
│   │   │
│   │   ├── hosts: web                # Target group from inventory
│   │   ├── become: true              # Run with sudo
│   │   ├── vars_files:
│   │   │   └── vars.yml              # External vars (e.g. repo_url, app_dir)
│   │   ├── roles:
│   │   │   └── docker                # 👇 Apply the docker role (link below)
│   │   │
│   │   └── ⤷ Executes → roles/docker/tasks/main.yml
│   │
│   └── 🟩 Play 2: "Cloud-1 bootstrap (Ubuntu target)"
│       │
│       ├── hosts: all
│       ├── become: true
│       ├── vars:                     # Inline vars (e.g. repo_url, app_dir)
│       └── tasks:                    # Manual setup tasks (apt, ufw, sshd, etc.)
│            ├── Update apt cache
│            ├── Install prerequisites
│            ├── Add Docker repo/key
│            ├── Install Docker CE
│            ├── Setup UFW + SSH hardening
│            ├── Clone repo
│            ├── Create systemd service
│            │      └── notify: daemon-reload  🔔
│            └── (other setup tasks)
│
│            ⤷ HANDLERS (at bottom of play 2)
│                └── daemon-reload → runs "systemctl daemon-reload"
│
│
└── 📁 roles/
    └── 📁 docker/
        ├── tasks/
        │   └── main.yml              # 🧩 Role task list
        │        │
        │        ├── Update apt cache
        │        ├── Install base pkgs
        │        ├── Add Docker key/repo
        │        ├── Install Docker
        │        ├── Enable docker service
        │        ├── Clone app repo
        │        ├── Ensure compose dir
        │        └── Run docker compose up -d
        │
        ├── vars/
        │   └── main.yml              # Default vars (optional)
        │
        ├── handlers/
        │   └── main.yml (optional)   # Define handler actions for this role
        │
        ├── templates/                # For Jinja2 templates (if any)
        └── files/                    # For static files to copy
```

## Execution Flow Overview
```yaml
START ▶ playbook.yml
          │
          ├──▶ Play 1: run role “docker”
          │       │
          │       └──▶ roles/docker/tasks/main.yml
          │               (installs Docker + compose stack)
          │
          └──▶ Play 2: bootstrap Ubuntu host
                  │
                  ├── run apt, ufw, ssh, git, etc.
                  ├── create systemd service
                  │       └── notify: daemon-reload 🔔
                  └──▶ handler "daemon-reload"
                             → runs systemctl daemon-reload

```

## 🧱 Concept Map Summary
```yaml
| Layer         | File                          | Role                 | What Happens                                |
| ------------- | ----------------------------- | -------------------- | ------------------------------------------- |
| **Top level** | `playbook.yml`                | Entry point          | Defines plays & references roles            |
| **Play 1**    | (inside playbook)             | Deploy Docker stack  | Calls role `docker`                         |
| **Play 2**    | (inside playbook)             | System setup         | Runs custom bootstrap tasks                 |
| **Role**      | `roles/docker/tasks/main.yml` | Docker setup logic   | Installs Docker, clones app, runs compose   |
| **Handler**   | defined in playbook or role   | Post-change callback | e.g., reload systemd when new service added |

```

## variable changing flow 


```
vars.yml
   │
   ▼
playbook.yml (vars_files)
   │
   ▼
roles/docker/tasks/main.yml
   │
   ├─ Create directory → uses {{ app_dir }}
   ├─ Clone repo → uses {{ repo_url }}, {{ repo_version }}
   └─ Compose stack → uses {{ compose_dir }}
           │
           ▼
systemd service content → WorkingDirectory={{ app_dir }}/compose

```
```yaml
📁 ansible/
│
├── vars.yml                     # External variable file
│     ├─ app_dir: /opt/cloud-1
│     ├─ repo_url: https://github.com/youruser/cloud-1.git
│     ├─ compose_dir: "{{ app_dir }}/compose"
│     └─ repo_version: main
│
├── playbook.yml
│     │
│     ├─ Play 1: Deploy cloud-1 compose stack
│     │       ├─ hosts: web
│     │       ├─ become: true
│     │       ├─ vars_files: vars.yml  ← imports variables here
│     │       └─ roles:
│     │             └─ docker
│     │                 │
│     │                 └─ tasks/main.yml
│     │                       │
│     │                       ├─ Uses {{ app_dir }} to create directories
│     │                       ├─ Uses {{ repo_url }} to clone repository
│     │                       └─ Uses {{ compose_dir }} to run Docker Compose
│     │
│     └─ Play 2: Cloud-1 bootstrap
│             ├─ hosts: all
│             ├─ become: true
│             └─ vars:
│                 ├─ app_dir: /opt/cloud-1       ← inline variable overrides
│                 ├─ repo_url: ...
│                 └─ repo_version: main
│
├── roles/docker/tasks/main.yml
│       ├─ Create directory: path={{ app_dir }}
│       ├─ Clone repo: repo={{ repo_url }}, dest={{ app_dir }}, version={{ repo_version }}
│       ├─ Ensure compose directory: path={{ compose_dir }}
│       └─ Start compose stack: docker compose -f {{ compose_dir }}/docker-compose.yml up -d
│
└── systemd service (inline content)
        ├─ WorkingDirectory={{ app_dir }}/compose
        └─ ExecStart=/usr/bin/docker compose up -d

```
1. `variable.yml`
- Central source of truth for paths, repo, and version.
- Loaded via varaibles_files in Play 1.
2. Playbook → Role
- Playbook passes variables down automatically into the role.
- Example: `{{ app_dir }}` in `tasks/main.yml` points to `/opt/cloud-1`.
3. Role tasks
- Use variables to:
 -- Create directories
 -- Clone Git repo
 -- Set working directory for Docker Compose
4. Systemd inline service
- Uses `{{ app_dir }}` to define WorkingDirectory and commands.
- Changes to `app_dir` in `variable.yml` propagate here automatically.
5. Overrides
Inline variables in Play 2 can override `variables.yml` if needed for specific hosts.


✅ Key Takeaways
- All variables flow top-down from vars.yml → playbook → role → task → inline systemd content.
- You can override variables at the play level or task level if needed.
- Using variables this way ensures idempotency and reusability.
---

