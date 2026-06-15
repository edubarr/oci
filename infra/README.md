# OCI Infrastructure

OpenTofu configuration for the OCI infrastructure used by this project.

The stack provisions one VCN, two public subnets, security rules for SSH/HTTP/HTTPS, two Ampere A1 compute instances with 100 GB boot volumes, and attaches existing reserved public IPv4 addresses to the instances.

## Resources

- `olympus-vcn`: IPv4/IPv6-enabled VCN.
- `chimera`: VM in `chimera-subnet`.
- `cerberus`: VM in `cerberus-subnet`.
- `route_table_chimera` and `route_table_cerberus`: public internet routing.
- `security_list_chimera` and `security_list_cerberus`: ingress for TCP ports `22`, `80`, and `443`, plus IPv4/IPv6 egress.
- Reserved public IPs imported from OCI and assigned to the VMs.

Each VM uses `VM.Standard.A1.Flex` with `2` OCPUs, `12` GB RAM, and a `100` GB boot volume.

## Files

- `main.tf`: OCI provider configuration.
- `network.tf`: VCN, gateway, route tables, security lists, and subnets.
- `compute.tf`: VM instances, reserved public IP bindings, and private IP lookup.
- `cloud-init.yaml`: base OS setup, Docker installation, and user bootstrap.
- `variables.tf`: input variables.
- `outputs.tf`: VM public IP outputs.
- `terraform.tfvars`: local variable values.

## Requirements

- OpenTofu installed.
- OCI API credentials configured in `~/.oci/config`.
- An OCI config profile matching `oci_profile` in `terraform.tfvars`.
- An AWS-compatible OCI Customer Secret Key configured in `~/.aws` as the `oci-personal` profile.
- An OCI Object Storage bucket for remote state.
- Existing reserved public IP OCIDs for `chimera` and `cerberus`.
- An Ubuntu image OCID for the target OCI region.

## Configuration

Set the required values in `terraform.tfvars`:

```hcl
oci_profile  = "PERSONAL"
tenancy_ocid = "ocid1.tenancy..."

vcn_cidr              = "10.0.0.0/16"
subnet_chimera_cidr   = "10.0.0.0/24"
subnet_cerberus_cidr  = "10.0.1.0/24"

ubuntu_image_ocid = "ocid1.image..."

eduardo_user_ssh_public_key = "ssh-ed25519 ..."

chimera_vm_reserved_ip_id  = "ocid1.publicip..."
cerberus_vm_reserved_ip_id = "ocid1.publicip..."
```

Only `eduardo_user_ssh_public_key` is configured for SSH access.

## Remote State

OpenTofu uses OCI Object Storage through the S3-compatible backend API.

The backend configuration lives in `main.tf`:

```hcl
backend "s3" {
  bucket = "<oci-object-storage-bucket-name>"
  key    = "oci/infra/terraform.tfstate"
  region = "sa-saopaulo-1"

  profile = "oci-personal"

  endpoints = {
    s3 = "https://<tenancy-namespace>.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_s3_checksum            = true
  use_path_style              = true
}
```

Update `main.tf` with:

- `bucket`: the OCI Object Storage bucket name.
- `endpoints.s3`: replace `<tenancy-namespace>` with the Object Storage namespace from OCI Tenancy Details.

The backend uses the local AWS profile `oci-personal`, so the OCI Customer Secret Key must already be configured in `~/.aws/credentials` for that profile.

The same placeholder values are also declared in `variables.tf` and `terraform.tfvars` for visibility. OpenTofu backend blocks are initialized before variables are loaded, so the backend cannot use `var.*` directly.

## Usage

Run all commands from this directory:

```bash
tofu init
tofu fmt
tofu validate
tofu plan
tofu apply
```

## Outputs

After apply, OpenTofu returns:

- `chimera_public_ip`: public IPv4 address for `chimera`.
- `cerberus_public_ip`: public IPv4 address for `cerberus`.

## VM Bootstrap

Cloud-init performs the base setup on each VM:

- Creates the `eduardo` user with passwordless sudo.
- Adds Eduardo's SSH public key.
- Installs Docker, Docker Compose plugin, Nginx, and Certbot.
- Adds `ubuntu` and `eduardo` to the Docker group.
- Opens HTTP and HTTPS in local iptables rules.
- Creates `/srv/overinspect` owned by `eduardo`.

SSH example:

```bash
ssh eduardo@<public-ip>
```
