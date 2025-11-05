#!/usr/bin/env bash
set -euo pipefail

# tools/test-with-multipass.sh
# Create a disposable Multipass VM, transfer the repo, install Ansible inside the VM
# and run syntax-check and a dry-run of the playbook. Optionally apply or destroy.

VM_NAME=${2:-cloud-test}
RELEASE=${3:-20.04}
ACTION=${1:-create}   # create | apply | destroy
REPO_DIR="/home/ubuntu/cloud-1"

usage(){
  cat <<EOF
Usage: $0 <create|apply|destroy> [vm-name] [ubuntu-release]

Examples:
  $0 create            # create 'cloud-test' VM (20.04) and run syntax-check + dry-run
  $0 apply my-vm 22.04 # run the playbook for real on 'my-vm' using Ubuntu 22.04
  $0 destroy my-vm     # delete the VM
EOF
  exit 1
}

if [[ "$ACTION" != "create" && "$ACTION" != "apply" && "$ACTION" != "destroy" ]]; then
  usage
fi

cmd(){
  echo "+ $*"
  "$@"
}

if [[ "$ACTION" == "destroy" ]]; then
  echo "==> deleting multipass VM '$VM_NAME'"
  cmd multipass delete "$VM_NAME"
  cmd multipass purge
  exit 0
fi

echo "==> launching multipass VM '$VM_NAME' (release=$RELEASE)"
cmd multipass launch --name "$VM_NAME" --mem 2G --disk 10G "$RELEASE"

echo "==> transferring repository to VM"
cmd multipass transfer . "$VM_NAME":"$REPO_DIR"

echo "==> preparing VM: install prerequisites and Ansible"
cmd multipass exec "$VM_NAME" -- bash -lc "
  sudo apt update -y && sudo apt install -y software-properties-common apt-transport-https ca-certificates curl gnupg && \
  sudo add-apt-repository --yes --update ppa:ansible/ansible && sudo apt update -y && sudo apt install -y ansible python3-apt git
"

echo "==> running ansible syntax-check inside VM"
cmd multipass exec "$VM_NAME" -- bash -lc "cd $REPO_DIR && ansible-playbook --syntax-check -i ansible/hosts.ini ansible/playbook.yml"

echo "==> running ansible dry-run (--check) inside VM"
set +e
cmd multipass exec "$VM_NAME" -- bash -lc "cd $REPO_DIR && ansible-playbook --check -i ansible/hosts.ini ansible/playbook.yml"
RC=$?
set -e

if [[ "$ACTION" == "apply" ]]; then
  echo "==> applying playbook for real inside VM (this will make changes)"
  cmd multipass exec "$VM_NAME" -- bash -lc "cd $REPO_DIR && ansible-playbook -i ansible/hosts.ini ansible/playbook.yml"
fi

if [[ $RC -ne 0 ]]; then
  echo "==> note: dry-run returned non-zero exit code ($RC). See output above for details."
  echo "If the failure is because a package (like docker-ce) is unavailable on the VM release, try using Ubuntu 20.04 (focal) or adjust the role to use distro-provided docker package (docker.io)."
else
  echo "==> dry-run completed successfully (exit 0)."
fi

echo "==> done. Use '$0 destroy $VM_NAME' to delete the VM when finished."
