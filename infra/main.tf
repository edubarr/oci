terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.17.0"
    }
  }
}

provider "oci" {
  config_file_profile = var.oci_profile
}


