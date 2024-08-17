variable "subnet_name" {
  type = string
  description = "To be created subnet name"
}

variable "cidr_range" {
  type = string
  description = "IP CIDR range for subnetwork"
}

variable "region" {
  type = string
  description = "GCP region name"
}

variable "public_ip_name" {
  type = string
  description = "Public IP name to be created"
}

variable "firewall_tag" {
  type = string
  description = "Tag for apache firewall open port 80"
  default = "allow-apache"
}

variable "instance_group" {
  description = "Instance group for LB target"
}