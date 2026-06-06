data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  environments = {
    chimera = {
      subnet_cidr    = var.subnet_chimera_cidr
      display_name   = "chimera"
      subnet_id      = oci_core_subnet.subnet_chimera.id
      reserved_ip_id = var.chimera_vm_reserved_ip_id
      fault_domain   = "FAULT-DOMAIN-2"
    }
    cerberus = {
      subnet_cidr    = var.subnet_cerberus_cidr
      display_name   = "cerberus"
      subnet_id      = oci_core_subnet.subnet_cerberus.id
      reserved_ip_id = var.cerberus_vm_reserved_ip_id
      fault_domain   = "FAULT-DOMAIN-3"
    }
  }
}

resource "oci_core_instance" "vm" {
  for_each = local.environments

  compartment_id      = var.tenancy_ocid # For root compartment, its the tenancy_ocid;
  display_name        = each.value.display_name
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  fault_domain        = each.value.fault_domain
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_ocid
  }

  create_vnic_details {
    subnet_id        = each.value.subnet_id
    assign_public_ip = false
    assign_ipv6ip    = true
    private_ip       = cidrhost(each.value.subnet_cidr, 10) # consistent .10 within each subnet
  }

  metadata = {
    ssh_authorized_keys = var.eduardo_user_ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      eduardo_ssh_key = var.eduardo_user_ssh_public_key
    }))
  }
}

import {
  for_each = local.environments
  to       = oci_core_public_ip.reserved_ip[each.key]
  id       = each.value.reserved_ip_id
}

data "oci_core_private_ips" "private_ip_datasource" {
  for_each = local.environments

  depends_on = [oci_core_instance.vm]

  subnet_id  = local.environments[each.key].subnet_id
  ip_address = cidrhost(local.environments[each.key].subnet_cidr, 10)
}

resource "oci_core_public_ip" "reserved_ip" {
  for_each = local.environments

  compartment_id = var.tenancy_ocid
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.private_ip_datasource[each.key].private_ips[0].id
}
