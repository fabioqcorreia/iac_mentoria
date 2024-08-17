terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }    
  }
}

# Networks

## VPC

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}

## Firewall

resource "google_compute_firewall" "rules" {
  name        = var.firewall_tag
  network     = google_compute_network.vpc_network.id
  description = "Allow Apache 2 server from ingress"

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.firewall_tag]
}



## Subnets

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

## Public IP

# resource "google_compute_address" "ip_address" {
#   name = var.public_ip_name
#   region = var.region
# }

## LB

# LB

module "gce-lb-http" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 10.0"
  name    = "lb-test"
  project = "study-251901"
  firewall_networks = [google_compute_network.vpc_network.name]

  backends = {
    default = {

      protocol    = "HTTP"
      port        = 80
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/"
        port         = 80
      }

      log_config = {
        enable      = false
      }

      groups = [
        {
          group = var.instance_group
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
}

