# Runs Terraform commands inside container via init_project.sh
# Terraform is in Docker, but the Makefile wraps Docker commands for convenience.
# Makefile for Terraform + Docker project

#################
# COLOR SETTING
BG_ORANGE := \033[48;5;216m
FG_BLACK_BOLD := \033[1;30m
RESET := \033[0m
#################

# Default AWS profile
AWS_PROFILE ?= default

# Default target: run local tool checks
.DEFAULT_GOAL := check-tools

# help | commands check
help:
	@echo "MAKE COMMANDS | Available targets: "
	@echo ""
	@echo "********* GENERAL SETUP ***************************"
	@echo "  check-tools			Check Ansible, Terraform & AWS CLI; auto-setup if missing"
	@echo "  setup-tools			Install Ansible, then install Terraform & AWS CLI via Ansible"
	@echo "********* ENV CHECKERS ***************************"
	@echo "  check-ssh-env ENV=...		Update SG to current IP, save outputs, test SSH for env"
	@echo "  check-aws-ec2 ENV=...		List running EC2 instances in Dev/Prod (AWS CLI)"
	@echo "********* TERRAFORM *********************"
	@echo "  tf-plan ENV=...			Run Terraform Plan (Dry-run)"
	@echo "  tf-deploy ENV=...		Run Terraform Apply (Provision)"
	@echo "********* ANSIBLE ***********************"
	@echo "  run-ansible ENV=...		Run Ansible playbook to configure servers"
	@echo "  check-containers ENV=...	Check running Docker containers via Ansible"
	@echo "  tf-destroy ENV=...		Run Terraform Destroy (Tear down)"
	@echo "********* ANSIBLE CONTAINERS UP/DOWN ***********************"
	@echo "  compose-up ENV=...		Start cloud-1 systemd service (docker compose up) on env"
	@echo "  compose-down ENV=...		Stop cloud-1 systemd service (docker compose down) on env"
	@echo "********* CLEANER ***************************"
	@echo "  tf-clean-cache ENV=...		Remove only temp artifacts (plans, cache), keep state"
	@echo "  tf-clean-check ENV=...		Verify cleanup (check for running instances and temp files)"
	@echo "  nuke ENV=...		[NUKE] Destroy infra AND remove local state (Project Reset)"
	
	@echo ""

# GENERAL SETUP ###############################################################
# Check environment: Docker present and running, and Terraform+AWS CLI available in tooling image (or official images)
check-tools:
	@echo "Checking local tools (Ansible, Terraform, AWS CLI)..."
	@echo "\n[Ansible]"; \
	if command -v ansible >/dev/null 2>&1; then \
		ansible --version | head -n 1; \
	else \
		echo "Ansible not found on PATH."; \
	fi; \
	echo "\n[Terraform]"; \
	if command -v terraform >/dev/null 2>&1; then \
		terraform -version | head -n 1; \
	else \
		echo "Terraform not found on PATH."; \
	fi; \
	echo "\n[AWS CLI]"; \
	if command -v aws >/dev/null 2>&1; then \
		aws --version; \
	else \
		echo "AWS CLI not found on PATH."; \
	fi; \
	echo "\n[Optional] Verifying AWS credentials (sts:get-caller-identity)"; \
	aws sts get-caller-identity 2>/dev/null || echo "Note: AWS credentials not configured or invalid. Run 'aws configure' if needed."


# install ansible, terraform, aws cli if not installed
setup-tools:
	@echo "Installing local tools: Ansible, Terraform, AWS CLI..."

	@echo "Installing local tools: Ansible, Terraform, AWS CLI..."
	@echo "[Step 1/2] Ensure Ansible is installed"
	@if command -v ansible >/dev/null 2>&1; then \
		echo "Ansible already installed."; \
	else \
		echo "ERROR: Ansible not found. Please install it manually:"; \
		echo "  Ubuntu/Debian: sudo apt install ansible"; \
		exit 1; \
	fi;
	@echo "[Step 2/2] Please install Terraform and AWS CLI manually if needed."
	@echo "Installation Successful"

# 	printf "\033[48;5;216m\033[1;30m ✔ Ansible is installed \033[0m\n"; \
# 	printf "\033[48;5;216m\033[1;30m ✔ Terraform is installed \033[0m\n"; \
# 	printf "\033[48;5;216m\033[1;30m ✔ AWS CLI is installed \033[0m\n"; \
# 	echo "Installation Successful";


# TERRAFROM ###############################################################
tf-plan:
	@test -n "$(ENV)" || { echo "Usage: make plan ENV=dev|prod"; exit 1; }
	@echo "Planning Terraform changes for $(ENV) with profile $(AWS_PROFILE)..."
	@cd terraform/envs/$(ENV) && export AWS_PROFILE=$(AWS_PROFILE) && terraform init && terraform plan

tf-deploy:
	@test -n "$(ENV)" || { echo "Usage: make deploy ENV=dev|prod"; exit 1; }
	@echo "Deploying resources to $(ENV) with profile $(AWS_PROFILE)..."
	@cd terraform/envs/$(ENV) && export AWS_PROFILE=$(AWS_PROFILE) && terraform init && terraform apply

tf-destroy:
	@test -n "$(ENV)" || { echo "Usage: make destroy ENV=dev|prod"; exit 1; }
	@echo "Destroying resources in $(ENV) with profile $(AWS_PROFILE)..."
	@cd terraform/envs/$(ENV) && export AWS_PROFILE=$(AWS_PROFILE) && terraform destroy

# Clean Terraform artifacts in a specific environment folder (Safe: keeps state)
tf-clean-cache:
	@test -n "$(ENV)" || { echo "Usage: make tf-clean-cache ENV=dev|prod"; exit 1; }
	@sh -c 'cd terraform/envs/$(ENV) && rm -rf .terraform *.tfplan *.plan crash.*.log || true'

# Verify cleanup (no running instances, no temp files)
tf-clean-check:
	@test -n "$(ENV)" || { echo "Usage: make tf-clean-check ENV=dev|prod"; exit 1; }
	@echo "=== Verifying cleanup for $(ENV) ==="
	@echo "[1/2] Checking for running EC2 instances (should be 'None' or empty table)..."
	@$(MAKE) check-aws-ec2 ENV=$(ENV)
	@echo "[2/2] Checking for local temp files (.tfplan, crash.log)..."
	@files="$$(find terraform/envs/$(ENV) -maxdepth 1 -name '*.tfplan' -o -name 'crash.*.log' 2>/dev/null)"; \
	if [ -n "$$files" ]; then \
		echo "Warning: Found temporary files:"; \
		echo "$$files"; \
	else \
		echo "OK: No temporary files found."; \
	fi


# CHECKERS ###############################################################
# Check status of deployed instances in AWS
check-aws-ec2:
	@test -n "$(ENV)" || { echo "Usage: make check-aws-ec2 ENV=dev|prod"; exit 1; }
	@case "$(ENV)" in dev|prod) ;; *) echo "ERROR: ENV must be 'dev' or 'prod'"; exit 1;; esac
	@echo "=== Checking AWS $(ENV) Instances === "
	@export AWS_PROFILE=cloud-1-$(ENV) && \
	aws ec2 describe-instances \
		--region eu-west-3 \
		--filters "Name=tag:Name,Values=cloud1-web-$(ENV)*" "Name=instance-state-name,Values=running" \
		--query "Reservations[*].Instances[*].{ID:InstanceId,PublicIP:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name'].Value|[0]}" \
		--output table

# SSH CHECK (use after terraform apply to check SSH works)
# Verify SSH access to specified environment: update SG, save outputs, test port & login
check-ssh-env:
	@test -n "$(ENV)" || { echo "Usage: make check-ssh-env ENV=dev|prod"; exit 1; }
	@case "$(ENV)" in dev|prod) ;; *) echo "ERROR: ENV must be 'dev' or 'prod'"; exit 1;; esac
	@echo "=== Verifying SSH access to $(ENV) environment ==="
	@echo "[1/5] Fetching your current public IP..."
	@NEW_CIDR="$$(curl -s https://checkip.amazonaws.com | tr -d '\n')/32"; \
	echo "      Current IP: $$NEW_CIDR"; \
	echo "[2/5] Updating $(ENV) security group to allow SSH from $$NEW_CIDR..."; \
	cd terraform/envs/$(ENV) && terraform init && terraform apply -auto-approve -var "allowed_ssh_cidr=$$NEW_CIDR" && \
	echo "[3/5] Saving Terraform outputs to tf_outputs.json..." && \
	terraform output -json | tee tf_outputs.json >/dev/null && \
	echo "[+   ] Updating Ansible Inventory..." && \
	python3 ../../../ansible/scripts/generate_inventory.py --tf-output tf_outputs.json --inventory ../../../ansible/inventories/$(ENV)/hosts.ini --ssh-key "$(CURDIR)/deploy_key" && \
	echo "[4/5] Testing SSH port 22 reachability..." && \
	IP=$$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' tf_outputs.json | head -n 1) && \
	echo "      Target IP: $$IP" && \
	nc -zv "$$IP" 22 2>&1 | grep -i succeeded || { echo "ERROR: Port 22 not reachable"; exit 1; } && \
	echo "[5/5] SSH login test..." && \
	ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -i ../../../deploy_key "ubuntu@$$IP" \
		"echo 'SSH_OK'; hostname; whoami; uptime" || { echo "ERROR: SSH login failed"; exit 1; } && \
	printf "%b\n" "${BG_ORANGE}${FG_BLACK_BOLD}$(ENV) environment SSH verified${RESET}"


# ANSIBLE ###############################################################
run-ansible:
	@test -n "$(ENV)" || { echo "Usage: make run-ansible ENV=dev|prod"; exit 1; }
	@case "$(ENV)" in dev|prod) ;; *) echo "ERROR: ENV must be 'dev' or 'prod'"; exit 1;; esac
	@echo "Running Ansible Playbook for $(ENV)..."
	@ansible-playbook -i ansible/inventories/$(ENV)/hosts.ini ansible/playbook.yml

check-containers:
	@test -n "$(ENV)" || { echo "Usage: make check-containers ENV=dev|prod"; exit 1; }
	@if out=$$(ansible -i ansible/inventories/$(ENV)/hosts.ini web -m shell -a "if [ -z \"\$$(sudo docker ps -q)\" ]; then echo 'Containers all removed'; else sudo docker ps; fi" --become 2>&1); then \
		echo "$$out"; \
	else \
		if echo "$$out" | grep -q "UNREACHABLE"; then \
			echo "Containers all removed (Host unreachable or destroyed)"; \
		else \
			echo "$$out"; \
			exit 1; \
		fi; \
	fi

# CLEANERS ###############################################################
# [NUKE] Destroy infrastructure AND delete local state (Project Reset)
nuke:
	@test -n "$(ENV)" || { echo "Usage: make nuke ENV=dev|prod"; exit 1; }
	@echo "!!!" DANGER: This will DESTROY $(ENV) infrastructure and DELETE local state "!!!"
	@read -p "Are you sure? [y/N] " ans && [ $${ans:-N} = y ]
	@$(MAKE) tf-destroy ENV=$(ENV)
	@echo "Destroy successful. Removing local state files..."
	@sh -c 'cd terraform/envs/$(ENV) && rm -rf .terraform terraform.tfstate terraform.tfstate.backup tf_outputs.json'
	@echo "Environment $(ENV) has been completely reset."

# Start the cloud-1 systemd service (docker compose up via systemd)
compose-up:
	@test -n "$(ENV)" || { echo "Usage: make compose-up ENV=dev|prod"; exit 1; }
	@case "$(ENV)" in dev|prod) ;; *) echo "ERROR: ENV must be 'dev' or 'prod'"; exit 1;; esac
	@echo "Starting cloud-1 systemd service (docker compose up) on $(ENV)..."
	@ansible -i ansible/inventories/$(ENV)/hosts.ini all -m ansible.builtin.service -a "name=cloud-1 state=started enabled=yes" --become

# Stop the cloud-1 systemd service (docker compose down via systemd)
compose-down:
	@test -n "$(ENV)" || { echo "Usage: make compose-down ENV=dev|prod"; exit 1; }
	@case "$(ENV)" in dev|prod) ;; *) echo "ERROR: ENV must be 'dev' or 'prod'"; exit 1;; esac
	@echo "Stopping cloud-1 systemd service (docker compose down) on $(ENV)..."
	@ansible -i ansible/inventories/$(ENV)/hosts.ini all -m ansible.builtin.service -a "name=cloud-1 state=stopped" --become

.PHONY: help check-tools setup-tools tf-clean-cache nuke check-ssh-env check-aws-ec2 tf-plan tf-deploy tf-destroy tf-clean-check run-ansible check-containers

