output "chimera_public_ip" {
  description = "Public IPv4 of the chimera VM"
  value       = oci_core_instance.vm["chimera"].public_ip
}

# output "cerberus_public_ip" {
#   description = "Public IPv4 of the cerberus VM"
#   value       = oci_core_instance.vm["cerberus"].public_ip
# }
