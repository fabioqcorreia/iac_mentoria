# output "public_ip_address" {
#   value = google_compute_address.ip_address.address
# }

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "firewall_tag" {
  value = var.firewall_tag
}

output "vpc_id" {
  value = google_compute_network.vpc_network.id
}