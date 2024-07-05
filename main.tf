provider "google" {
  project     = "study-251901"
  region      = "us-central1"
  zone        = "us-central1-b"
}

resource "google_compute_address" "ip_address" {
  name = "priv-ip"
}

resource "google_compute_instance" "vm_a" {
  name         = "vm-a"
  machine_type = "e2-standard-2"
  zone        = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
        nat_ip = google_compute_address.ip_address.address
    }
  }

}