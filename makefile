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

# Docker image name
IMAGE_NAME := terraform-aws-env

# Optional: set AUTO_BUILD=1 to allow automatic image build when missing
# By default we do NOT build automatically to avoid unexpected failures.
AUTO_BUILD ?= 0

# Function to ensure Docker image exists (POSIX sh compatible)
define ensure_docker_image
	@if [ -z "$$($(docker) images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "Docker image '$(IMAGE_NAME)' not found."; \
		if [ "$$AUTO_BUILD" = "1" ]; then \
			echo "AUTO_BUILD=1 set — building local image..."; \
			./init_project.sh; \
		else \
			echo "Set 'AUTO_BUILD=1' to allow automatic builds, or run 'make build-env' to build manually."; \
			exit 1; \
		fi; \
	else \
		echo "Docker image '$(IMAGE_NAME)' exists."; \
	fi
endef

# Default target: run local tool checks
.DEFAULT_GOAL := check-tools

# help | commands check
help:
	@echo "MAKE COMMANDS | Available targets: "
	@echo ""
	@echo "  check-tools			Check Ansible, Terraform & AWS CLI; auto-setup if missing"
	@echo "  setup-tools			Install Ansible, then install Terraform & AWS CLI via Ansible"
	@echo "  compose-up			Start docker-compose stack (compose/docker-compose.yml)"
	@echo "  compose-down			Stop docker-compose stack (compose/docker-compose.yml)"
	@echo "  clean				Remove local Docker image and prune unused resources"
	@echo "  clean-check			Check for running containers, dangling images, or local images"
	@echo "  terraform-clean		Remove local Terraform artifacts (state, plans, cache)"
	@echo "  terraform-clean-env ENV=dev|prod	Clean Terraform artifacts for a specific environment (need to specify ENV=dev or ENV=prod)"
	@echo "  terraform-clean-all		Clean Terraform artifacts in both dev and prod"
	@echo "  check-ssh-dev			Update dev SG to current IP, save outputs, test SSH (port 22 + login)"
	@echo "  check-ssh-prod		Update prod SG to current IP, save outputs, test SSH (port 22 + login)"
	@echo ""


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

# ANSIBLE 
	@echo "\n[Step 1/3] Ensure Ansible is installed"
	@if command -v ansible >/dev/null 2>&1; then \
 		echo "Ansible already installed."; \
	else \
		if command -v brew >/dev/null 2>&1; then \
			echo "Installing Ansible via Homebrew..."; \
			brew update >/dev/null 2>&1 || true; \
			brew install ansible || { echo "Failed to install Ansible with Homebrew"; exit 1; }; \
		elif command -v pipx >/dev/null 2>&1; then \
			echo "Installing Ansible via pipx..."; \
			pipx install ansible || { echo "Failed to install Ansible with pipx"; exit 1; }; \
		elif command -v pip3 >/dev/null 2>&1; then \
			echo "Installing Ansible via pip3 --user..."; \
			pip3 install --user ansible || { echo "Failed to install Ansible with pip3"; exit 1; }; \
			echo "NOTE: You may need to add the user base bin dir to PATH (e.g., $$($$(/usr/bin/env python3 -c 'import site,sys;sys.stdout.write(site.USER_BASE)'))/bin)."; \
		else \
			echo "ERROR: Could not find Homebrew, pipx, or pip3 to install Ansible."; \
			echo "Please install Homebrew first: /bin/bash -c \"$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
			exit 1; \
		fi; \
	fi; \

# TERRAFORM & AWS CLI
	@echo "\n[Step 2/3] Install Terraform & AWS CLI via Ansible"; \
	ag_bin=ansible-galaxy; \
	if ! command -v $$ag_bin >/dev/null 2>&1; then \
		user_bin_dir="$$($$(/usr/bin/env python3 -c 'import site,sys;sys.stdout.write(site.USER_BASE)'))/bin"; \
		[ -x "$$user_bin_dir/ansible-galaxy" ] && ag_bin="$$user_bin_dir/ansible-galaxy"; \
	fi; \
	"$$ag_bin" collection install community.general || true; \
	pb_bin=ansible-playbook; \
	if ! command -v $$pb_bin >/dev/null 2>&1; then \
		user_bin_dir="$$($$(/usr/bin/env python3 -c 'import site,sys;sys.stdout.write(site.USER_BASE)'))/bin"; \
		[ -x "$$user_bin_dir/ansible-playbook" ] && pb_bin="$$user_bin_dir/ansible-playbook"; \
	fi; \
	( cd "$(CURDIR)/ansible" && ANSIBLE_CONFIG="ansible.cfg" "$$pb_bin" tools.yml ); \

# FINAL CHECK 	
	@echo "\n[Step 3/3] Verify installations"; \
	command -v ansible >/dev/null 2>&1 && ansible --version | head -n 1 || echo "Ansible not found"; \
	command -v terraform >/dev/null 2>&1 && terraform -version | head -n 1 || echo "Terraform not found"; \
	command -v aws >/dev/null 2>&1 && aws --version || echo "AWS CLI not found"; \
	
# 	@echo "$(BG_ORANGE)Installation Successful$(RESET)";
	@printf "\033[48;5;216m\033[1;30m Installation Successful \033[0m\n"

# 	printf "\033[48;5;216m\033[1;30m ✔ Ansible is installed \033[0m\n"; \
# 	printf "\033[48;5;216m\033[1;30m ✔ Terraform is installed \033[0m\n"; \
# 	printf "\033[48;5;216m\033[1;30m ✔ AWS CLI is installed \033[0m\n"; \
# 	echo "Installation Successful";


# Convenience targets for docker-compose and cleanup
compose-up:
	@echo "Starting compose stack from compose/docker-compose.yml..."
	@docker compose -f compose/docker-compose.yml up -d

compose-down:
	@echo "Stopping compose stack (compose/docker-compose.yml)..."
	@docker compose -f compose/docker-compose.yml down --volumes --remove-orphans || true

# Consolidated clean target: stop compose, remove tooling image, prune and verify
clean: compose-down
	@echo "Removing local tooling image '$(IMAGE_NAME)' if present..."
	@ids="$$(docker images -q $(IMAGE_NAME) 2> /dev/null || true)"; \
	if [ -n "$$ids" ]; then \
		echo "Found image ids: $$ids"; \
		for id in $$ids; do \
			echo "Removing $$id..."; \
			docker rmi -f $$id || true; \
		done; \
		# small retry in case Docker needs a moment to release layers; \
		sleep 1; \
		ids2="$$(docker images -q $(IMAGE_NAME) 2> /dev/null || true)"; \
		if [ -n "$$ids2" ]; then \
			echo "Retry removing remaining images: $$ids2"; \
			for id in $$ids2; do docker rmi -f $$id || true; done; \
		fi; \
	else \
		echo "No local tooling image '$(IMAGE_NAME)' present."; \
	fi
	@echo "Pruning unused docker resources (dangling images, stopped containers, networks)..."
	@docker system prune -f || true
	@echo "Verifying no running containers or dangling images remain..."
	@$(MAKE) clean-check


# Check for hanging containers/images. Exits non-zero if anything is found.
clean-check:
	@echo "Checking for running containers..."
	@if [ -n "$$(docker ps -q)" ]; then \
		echo "ERROR: There are running containers:"; \
		docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}'; \
		exit 1; \
	else \
		echo "No running containers."; \
	fi
	@echo "Checking for dangling images..."
	@if [ -n "$$(docker images -f dangling=true -q)" ]; then \
		echo "ERROR: Dangling images exist:"; \
		docker images -f dangling=true; \
		exit 1; \
	else \
		echo "No dangling images."; \
	fi
	@echo "Checking for local tooling image '$(IMAGE_NAME)'..."
	@if [ -n "$$(docker images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "ERROR: Local tooling image '$(IMAGE_NAME)' still present:"; \
		docker images $(IMAGE_NAME); \
		exit 1; \
	else \
		echo "No local tooling image '$(IMAGE_NAME)' present."; \
	fi
	@echo "\nclean-check: OK\n"

# Remove Terraform-generated artifacts to avoid accidental commits and push failures
terraform-clean:
	@echo "Cleaning Terraform artifacts in terraform/ ..."
	@sh -c 'cd terraform && rm -rf .terraform *.tfstate *.tfstate.backup *.tfplan *.plan crash.*.log || true'
	@echo "Done. Consider re-running: terraform init"

# Clean Terraform artifacts in a specific environment folder (requires ENV)
terraform-clean-env:
	@test -n "$(ENV)" || { echo "Usage: make terraform-clean-env ENV=dev|prod"; exit 1; }
	@case "$(ENV)" in dev|prod) ;; *) echo "ERROR: ENV must be 'dev' or 'prod'"; exit 1;; esac
	@echo "Cleaning Terraform artifacts in terraform/envs/$(ENV)/ ..."
	@sh -c 'cd terraform/envs/$(ENV) && rm -rf .terraform terraform.tfstate terraform.tfstate.backup tf_outputs.json *.tfplan *.plan crash.*.log || true'
	@echo "Done. Consider re-running: terraform init in terraform/envs/$(ENV)"

# Clean Terraform artifacts in both dev and prod environment folders
terraform-clean-all:
	@for d in dev prod; do \
		echo "Cleaning Terraform artifacts in terraform/envs/$$d/ ..."; \
		sh -c 'cd terraform/envs/'"$$d"' && rm -rf .terraform terraform.tfstate terraform.tfstate.backup tf_outputs.json *.tfplan *.plan crash.*.log || true'; \
	done; \
	echo "Done. Consider re-running: terraform init per env"

# SSH CHECK (use after terrafrom apply to check SSH works)
# Verify SSH access to dev environment: update SG, save outputs, test port & login
check-ssh-dev:
	@echo "=== Verifying SSH access to dev environment ==="
	@echo "[1/5] Fetching your current public IP..."
	@NEW_CIDR="$$(curl -s https://checkip.amazonaws.com | tr -d '\n')/32"; \
	echo "      Current IP: $$NEW_CIDR"; \
	echo "[2/5] Updating dev security group to allow SSH from $$NEW_CIDR..."; \
	cd terraform/envs/dev && terraform apply -auto-approve -var "allowed_ssh_cidr=$$NEW_CIDR" && \
	echo "[3/5] Saving Terraform outputs to tf_outputs.json..." && \
	terraform output -json | tee tf_outputs.json >/dev/null && \
	echo "[4/5] Testing SSH port 22 reachability..." && \
	IP="$$(terraform output -raw webserver_public_ip)" && \
	echo "      Target IP: $$IP" && \
	nc -zv "$$IP" 22 2>&1 | grep -i succeeded || { echo "ERROR: Port 22 not reachable"; exit 1; } && \
	echo "[5/5] SSH login test..." && \
	ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -i ~/.ssh/id_ed25519 "ubuntu@$$IP" \
		"echo 'SSH_OK'; hostname; whoami; uptime" || { echo "ERROR: SSH login failed"; exit 1; } && \
	printf "%b\n" "${BG_ORANGE}${FG_BLACK_BOLD}DEV environment SSH verified${RESET}"

# Verify SSH access to prod environment: update SG, save outputs, test port & login
check-ssh-prod:
	@echo "=== Verifying SSH access to prod environment ==="
	@echo "[1/5] Fetching your current public IP..."
	@NEW_CIDR="$$(curl -s https://checkip.amazonaws.com | tr -d '\n')/32"; \
	echo "      Current IP: $$NEW_CIDR"; \
	echo "[2/5] Updating prod security group to allow SSH from $$NEW_CIDR..."; \
	cd terraform/envs/prod && terraform apply -auto-approve -var "allowed_ssh_cidr=$$NEW_CIDR" && \
	echo "[3/5] Saving Terraform outputs to tf_outputs.json..." && \
	terraform output -json | tee tf_outputs.json >/dev/null && \
	echo "[4/5] Testing SSH port 22 reachability..." && \
	IP="$$(terraform output -raw webserver_public_ip)" && \
	echo "      Target IP: $$IP" && \
	nc -zv "$$IP" 22 2>&1 | grep -i succeeded || { echo "ERROR: Port 22 not reachable"; exit 1; } && \
	echo "[5/5] SSH login test..." && \
	ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -i ~/.ssh/id_ed25519 "ubuntu@$$IP" \
		"echo 'SSH_OK'; hostname; whoami; uptime" || { echo "ERROR: SSH login failed"; exit 1; } && \
	printf "%b\n" "${BG_ORANGE}${FG_BLACK_BOLD}PROD environment SSH verified${RESET}"

.PHONY: help check-tools setup-tools  compose-up compose-down clean clean-check terraform-clean terraform-clean-env terraform-clean-all check-ssh-dev check-ssh-prod
# .PHONY: terraform-clean

#############
# Build the tooling image (context is the 'docker' directory)
# docker build -t terraform-aws-env -f docker/terraform-aws.Dockerfile docker

# # Verify versions in the rebuilt image
# docker run --rm terraform-aws-env terraform --version
# docker run --rm terraform-aws-env aws --version
#############