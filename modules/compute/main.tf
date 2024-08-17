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

resource "google_compute_instance" "instance" {
  name         = var.vm_name
  machine_type = var.vm_type
  zone         = var.zone

  tags = [var.firewall_tag]

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  dynamic "scheduling" {
    for_each = [var.provisioning_model]
    content {
      provisioning_model = var.provisioning_model
      automatic_restart = var.provisioning_model == "SPOT" ? false : true
      preemptible = var.provisioning_model == "SPOT" ? true : false
    }
  }

  network_interface {
    subnetwork = var.subnet
    network = var.vpc_id
    
    dynamic "access_config" {
      for_each = var.public_ip != "" ? [1] : [0] 
      content {
        nat_ip = var.public_ip 
      }
    }
  }

  metadata_startup_script = var.startup_script

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account_email
    scopes = [var.scope]
  }

}

