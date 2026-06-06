resource "oci_core_vcn" "vcn" {
  compartment_id = var.tenancy_ocid # For root compartment, its the tenancy_ocid;
  display_name   = "olympus-vcn"
  cidr_block     = var.vcn_cidr
  is_ipv6enabled = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "igw"
}

resource "oci_core_route_table" "route_table_chimera" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "route_table_chimera"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_route_table" "route_table_cerberus" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "route_table_cerberus"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

locals {
  security_ingress_rules = [
    { source = "0.0.0.0/0", protocol = "6", tcp_min = 80, tcp_max = 80 },
    { source = "0.0.0.0/0", protocol = "6", tcp_min = 443, tcp_max = 443 },
    { source = "0.0.0.0/0", protocol = "6", tcp_min = 22, tcp_max = 22 },
    { source = "::/0", protocol = "6", tcp_min = 80, tcp_max = 80 },
    { source = "::/0", protocol = "6", tcp_min = 443, tcp_max = 443 },
    { source = "::/0", protocol = "6", tcp_min = 22, tcp_max = 22 },
  ]

  security_egress_rules = [
    { destination = "0.0.0.0/0", protocol = "6" },
    { destination = "::/0", protocol = "6" },
  ]
}

resource "oci_core_security_list" "security_list_chimera" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "security_list_chimera"

  dynamic "egress_security_rules" {
    for_each = local.security_egress_rules
    content {
      destination = egress_security_rules.value.destination
      protocol    = egress_security_rules.value.protocol
    }
  }

  dynamic "ingress_security_rules" {
    for_each = local.security_ingress_rules
    content {
      source   = ingress_security_rules.value.source
      protocol = ingress_security_rules.value.protocol
      tcp_options {
        min = ingress_security_rules.value.tcp_min
        max = ingress_security_rules.value.tcp_max
      }
    }
  }
}

resource "oci_core_security_list" "security_list_cerberus" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "security_list_cerberus"

  dynamic "egress_security_rules" {
    for_each = local.security_egress_rules
    content {
      destination = egress_security_rules.value.destination
      protocol    = egress_security_rules.value.protocol
    }
  }

  dynamic "ingress_security_rules" {
    for_each = local.security_ingress_rules
    content {
      source   = ingress_security_rules.value.source
      protocol = ingress_security_rules.value.protocol
      tcp_options {
        min = ingress_security_rules.value.tcp_min
        max = ingress_security_rules.value.tcp_max
      }
    }
  }
}

resource "oci_core_subnet" "subnet_chimera" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "chimera-subnet"
  cidr_block        = var.subnet_chimera_cidr
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 0)
  route_table_id    = oci_core_route_table.route_table_chimera.id
  security_list_ids = [oci_core_security_list.security_list_chimera.id]
}

resource "oci_core_subnet" "subnet_cerberus" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "cerberus-subnet"
  cidr_block        = var.subnet_cerberus_cidr
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 1)
  route_table_id    = oci_core_route_table.route_table_cerberus.id
  security_list_ids = [oci_core_security_list.security_list_cerberus.id]
}
