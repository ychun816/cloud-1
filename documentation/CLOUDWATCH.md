# Monitoring with Amazon CloudWatch Agent

## 1. What is the CloudWatch Agent
The Amazon CloudWatch Agent is a piece of software installed on your EC2 instances. While AWS automatically tracks basic metrics (like CPU usage and Network traffic), it **cannot** see inside your operating system to measure memory (RAM) or disk space usage.

The CloudWatch Agent bridges this gap by reading system logs and performance counters from inside the OS and sending them to the AWS CloudWatch Console.

## 2. How It Is Configured in This Project

We automated the installation using Ansible so you don't have to run the manual `amazon-cloudwatch-agent-config-wizard`.

### Components:
1.  **IAM Role (`iam.tf`):**
    *   **Purpose:** Gives the EC2 server permission (`CloudWatchAgentServerPolicy`) to upload data to AWS. Without this, the agent would get "Access Denied" errors.

2.  **Ansible Role (`ansible/roles/cloudwatch/`):**
    *   **Tasks (`tasks/main.yml`):** Downloads the `.deb` package, installs it, copies the config file, and starts the service.
    *   **Configuration (`templates/amazon-cloudwatch-agent.json.j2`):** A JSON file defining exactly *what* to measure (Disk Used %, Memory Used %).

## 3. How to Verify It Is Working

After deploying your project with `ansible-playbook`:

1.  **Log in to AWS Console.**
2.  Navigate to **CloudWatch** service.
3.  On the left menu, click **Metrics** -> **All metrics**.
4.  Look for a custom namespace called **CWAgent** (this only appears if the agent is working).
5.  Click **CWAgent**. You will see two categories:
    *   **ImageId, InstanceId, InstanceType** -> Contains `mem_used_percent` (Memory).
    *   **ImageId, InstanceId, InstanceType, device, fstype, path** -> Contains `disk_used_percent` (Disk storage).
6.  Select a metric to view the graph.

## 4. Troubleshooting

If metrics are not appearing:

1.  **Check Service Status:**
    SSH into your server and run:
    ```bash
    sudo systemctl status amazon-cloudwatch-agent
    ```
    It should say "active (running)".

2.  **Check Logs:**
    The agent writes its own logs locally. Check them for errors:
    ```bash
    cat /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
    ```

3.  **Verify IAM Role:**
    Ensure your EC2 instance actually has the IAM role attached in the AWS Console (Select Instance -> Actions -> Security -> Modify IAM Role).
