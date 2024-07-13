provider "google" {
  project = "study-251901"
  region  = "us-central1"
  zone    = "us-central1-b"
}

# IAM

## Service accounts

resource "google_service_account" "compute_admin_service_account" {
  account_id   = "compute-service-account"
  display_name = "Compute Engine Service Account"
}

resource "google_project_iam_member" "sa_user_account_iam" {
  project = "study-251901"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.compute_admin_service_account.email}"
}

resource "google_project_iam_member" "admin_account_iam" {
  project = "study-251901"
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.compute_admin_service_account.email}"
}



## Granular service account
# 
# Details on how to proceed: https://cloud.google.com/compute/docs/access/iam?hl=pt-br#compute.instanceAdmin
#
# resource "google_project_iam_custom_role" "basic_custom_role" {
#   role_id     = "computeBasicCustomRole"
#   title       = "Google Cloud Compute Basic Custom Role"
#   description = "Papel criado para ter controle básico dos serviços google cloud"
#   permissions = [
#     "compute.addresses.create", 
#     "iam.roles.create", 
#     "iam.roles.delete"
#   ]
# }

# Networks

## VPC

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}

## Subnets

resource "google_compute_subnetwork" "subnet-a" {
  name          = "subnet-a"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "subnet-b" {
  name          = "subnet-b"
  region        = "us-east1"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc_network.id
}

## Public IP

resource "google_compute_address" "ip_address" {
  name = "public-ip"
}

## Firewall

resource "google_compute_firewall" "rules" {
  name        = "allow-apache"
  network     = google_compute_network.vpc_network.id
  description = "Allow Apache 2 server from ingress"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-apache"]

}


resource "google_compute_instance" "vm_a" {
  name         = "vm-a"
  machine_type = "e2-standard-2"
  zone         = "us-central1-a"

  tags = ["allow-apache"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet-a.name
    network = google_compute_network.vpc_network.id
    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata_startup_script = "apt update && apt install apache2 -y"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.compute_admin_service_account.email
    scopes = ["cloud-platform"]
  }

}

