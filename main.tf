terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }    
  }
}
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

module "network_a" {
  source = "./modules/network"
  cidr_range = "10.0.1.0/24"
  subnet_name = "subnet-a"
  region = "us-central1"
  public_ip_name = "public-ip-a"
  instance_group = google_compute_instance_group.webservers.self_link
}

# module "network_b" {
#   source = "./modules/network"
#   cidr_range = "10.0.2.0/24"
#   subnet_name = "subnet-b"
#   region = "us-east1"
#   public_ip_name = "public-ip-b"
# }

## Instance Group

resource "google_compute_instance_group" "webservers" {
  depends_on = [ module.vm_a, module.vm_b ]
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    module.vm_a.vm_id,
    module.vm_b.vm_id,
  ]

  named_port {
    name = "http"
    port = "80"
  }

}

# Compute module

module "vm_a" {
  source = "./modules/compute"
  subnet = module.network_a.subnet_name
  vpc_id = module.network_a.vpc_id
  vm_name = "vm-a"
  service_account_email = google_service_account.compute_admin_service_account.email
  firewall_tag = module.network_a.firewall_tag
  provisioning_model = "STANDARD"
  zone = "us-central1-b"
}

module "vm_b" {
  source = "./modules/compute"
  subnet = module.network_a.subnet_name
  vpc_id = module.network_a.vpc_id
  vm_name = "vm-b"
  service_account_email = google_service_account.compute_admin_service_account.email
  firewall_tag = module.network_a.firewall_tag
  provisioning_model = "SPOT"
  zone = "us-central1-b"
}

