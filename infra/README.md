# Efficace Infrastructure

Repository for infrastructure related files.

## OpenTofu Stack for OCI VMs

This stack creates two VMs on Oracle Cloud Infrastructure (OCI) using the Always Free tier resources. Each VM is configured with 2 OCPUs and 12GB RAM on Ampere A1 processors, and supports both IPv4 and IPv6 connectivity.

The configuration is organized into the following files:
- `main.tf`: Provider and data sources
- `network.tf`: Network resources (VCN, subnets, security lists, etc.)
- `compute.tf`: VM instances
- `variables.tf`: Variable declarations
- `outputs.tf`: Output definitions
- `terraform.tfvars`: Variable values

- **efficace-prod**: For production workloads.
- **efficace-dev**: For development, homologation, and observability workloads.

### Prerequisites

- Oracle Cloud account with Always Free tier enabled.
- OpenTofu installed (https://opentofu.org/).
- OCI CLI configured or API keys set up.

### Setup

1. Clone this repository and navigate to the infra directory.

2. Navigate to the efficace folder:
   ```bash
   cd efficace
   ```

3. Create a `terraform.tfvars` file with the corresponding variables, use example.tfvars as base.

3. Initialize OpenTofu:

   ```bash
   tofu init
   ```

4. Plan the deployment:

   ```bash
   tofu plan
   ```

5. Apply the stack:

   ```bash
   tofu apply
   ```

### Outputs

After deployment, the public IPs of the VMs will be displayed:

- `efficace_prod_public_ip`: Public IPv4 for the efficace-prod VM.
- `efficace_prod_ipv6`: IPv6 address for the efficace-prod VM.
- `efficace_dev_public_ip`: Public IPv4 for the efficace-dev VM.
- `efficace_dev_ipv6`: IPv6 address for the efficace-dev VM.

### User Configuration and Docker Setup

The VMs are configured with cloud-init to automatically:

1. **Create additional users**: `deploy` and `eduardo` with sudo privileges
2. **Configure SSH access**: Each user has their SSH public key configured for passwordless login
3. **Install Docker**: Docker CE is installed and configured to start on boot
4. **Add users to Docker group**: All users can run Docker commands without sudo

#### SSH Keys Configuration

Update the `terraform.tfvars` file with the actual SSH public keys for the deploy and eduardo users:

```hcl
deploy_user_ssh_public_key  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."  # Replace with actual deploy user SSH public key
eduardo_user_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."  # Replace with actual eduardo user SSH public key
```

#### User Access

After deployment, you can SSH into the VMs using:

```bash
# SSH as deploy user
ssh -i ~/.ssh/deploy_key deploy@<vm_public_ip>

# SSH as eduardo user
ssh -i ~/.ssh/eduardo_key eduardo@<vm_public_ip>

# SSH as root (using the original keys)
ssh -i ~/.ssh/root_key root@<vm_public_ip>
```

#### Docker Usage

Docker is pre-installed and users can run Docker commands directly:

```bash
docker run hello-world
docker ps
```
