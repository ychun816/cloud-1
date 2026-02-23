import subprocess
import sys

ENV = "dev"

# Helper to run local shell commands with real-time output
def run_local(cmd, check=True):
    print(f"\n[LOCAL] $ {cmd}")
    process = subprocess.Popen(cmd, shell=True)
    process.communicate()
    if check and process.returncode != 0:
        print(f"Command failed: {cmd}")
        sys.exit(process.returncode)

if __name__ == "__main__":
    print("\n[INFO] Destroying EC2 instance and cleaning up...")
    run_local(f"make tf-destroy ENV={ENV}")
    run_local(f"make tf-clean-cache ENV={ENV}")
    run_local(f"make tf-clean-check ENV={ENV}")
    run_local(f"make check-aws-ec2 ENV={ENV}")
    print("\n[INFO] Teardown complete. Check above for any remaining resources.")
