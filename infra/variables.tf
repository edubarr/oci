variable "oci_profile" {
  description = "OCI configuration profile"
  type        = string
}

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
}

variable "chimera_vm_reserved_ip_id" {
  description = "Reserved public IP for chimera VM"
  type        = string
}

variable "cerberus_vm_reserved_ip_id" {
  description = "Reserved public IP for cerberus VM"
  type        = string
}

variable "eduardo_user_ssh_public_key" {
  description = "SSH public key for the eduardo user"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "subnet_chimera_cidr" {
  description = "CIDR block for the chimera subnet"
  type        = string
}

variable "subnet_cerberus_cidr" {
  description = "CIDR block for the cerberus subnet"
  type        = string
}

variable "ubuntu_image_ocid" {
  description = "OCID of the Ubuntu image to use for VMs"
  type        = string
}
