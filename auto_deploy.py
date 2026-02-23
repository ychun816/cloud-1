# Local script/Makefile = manual (but automated), runs locally
import subprocess
import sys
import os
import time
import paramiko

# CONFIGURATION
ENV = "dev"
DEPLOY_KEY = "deploy_key"
SSH_USER = "ubuntu"
CLOUDWATCH_COMMANDS = [
    "sudo systemctl enable amazon-cloudwatch-agent",
    "sudo systemctl start amazon-cloudwatch-agent",
    "ps aux | grep amazon-cloudwatch-agent",
    "sudo systemctl status amazon-cloudwatch-agent",
    "tail -n 20 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
]

# Helper to run local shell commands
def run_local(cmd, check=True, capture=False):
    print(f"\n[LOCAL] $ {cmd}")
    if capture:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if check and result.returncode != 0:
            print(f"Command failed: {cmd}")
            print(result.stderr)
            sys.exit(result.returncode)
        return result.stdout.strip()
    else:
        process = subprocess.Popen(cmd, shell=True)
        process.communicate()
        if check and process.returncode != 0:
            print(f"Command failed: {cmd}")
            sys.exit(process.returncode)
        return ""

# Helper to SSH and run remote commands
def run_ssh(ip, key_path, commands):
    print(f"\n[SSH] Connecting to {SSH_USER}@{ip} ...")
    key = paramiko.RSAKey.from_private_key_file(key_path)
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(ip, username=SSH_USER, pkey=key)
    for cmd in commands:
        print(f"\n[REMOTE] $ {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        err = stderr.read().decode()
        if err:
            print(err)
    ssh.close()

# 1. Pre-deployment checks
run_local("make check-tools")

# 2. Terraform deploy
run_local(f"make tf-deploy ENV={ENV}")

# 3. Update SG, save outputs, test SSH
run_local(f"make init-ssh-ec2 ENV={ENV}")

# 4. Check EC2 instance is running
run_local(f"make check-aws-ec2 ENV={ENV}")

# 5. Run Ansible
run_local(f"make run-ansible ENV={ENV}")

# 6. Get EC2 public IP from Terraform output
def get_ec2_ip():
    output = run_local(f"cd terraform/envs/{ENV} && terraform output -json webserver_public_ips", check=False, capture=True)
    import json
    try:
        ips = json.loads(output)
        # Handle plain list output: ["13.39.109.165"]
        if isinstance(ips, list) and len(ips) > 0:
            return ips[0]
        # Handle dict output: {"value": ["13.39.109.165"], ...}
        elif isinstance(ips, dict) and 'value' in ips and isinstance(ips['value'], list) and len(ips['value']) > 0:
            return ips['value'][0]
        # Handle string output
        elif isinstance(ips, str):
            return ips
        else:
            print(f"Unexpected Terraform output format: {ips}")
            sys.exit(1)
    except Exception as e:
        print(f"Could not parse EC2 IP from Terraform output. Error: {e}")
        sys.exit(1)

EC2_IP = get_ec2_ip()
print(f"\n[INFO] EC2 Public IP: {EC2_IP}")

# 7. SSH into EC2 and start/check CloudWatch agent
run_ssh(EC2_IP, DEPLOY_KEY, CLOUDWATCH_COMMANDS)

print("\n[INFO] All steps completed: launch ec2, connect via SSH, start CloudWatch agent, check status and logs")
print("\n[NEXT STEPS]")
print(f"\nVerify application endpoints:\n - WordPress: https://{EC2_IP}\n - Adminer: https://{EC2_IP}/adminer")