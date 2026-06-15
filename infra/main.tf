terraform {
  backend "s3" {
    bucket = "terraform-states"
    key    = "oci/infra/terraform.tfstate"
    region = "sa-saopaulo-1"

    profile = "oci-personal"

    endpoints = {
      s3 = "https://grb9rbehl8ha.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }

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
