variable "vm_name" {
  type = string
  description = "VM name"
}

variable "firewall_tag" {
  type = string
  description = "Firewall network tags"
}

variable "vm_type" {
  type = string
  description = "VM type"
  default = "e2-small"
}

variable "zone" {
  type = string
  description = "Default VM zone"
  default = "us-central1-a"
}

variable "image_name" {
  type = string
  description = "OS image"
  default = "debian-cloud/debian-11"
}

variable "provisioning_model" {
  type = string
  description = "Provisioning model for VM, one of [STANDARD, SPOT]"
  default = "STANDARD"
  validation {
    condition = contains(["STANDARD", "SPOT"],var.provisioning_model)
    error_message = "Please set up one of ['STANDARD', 'SPOT']"
  }
}

variable "subnet" {
  type = string
  description = "Subnetwork name"
}

variable "vpc_id" {
  type = string
  description = "VPC network id"
}

variable "startup_script" {
  type = string
  description = "VM Startup script"
  default = "apt update && apt install apache2 -y && echo '<h1>$(hostname -a)</h1> > /var/www/html/index.html"
}

variable "public_ip" {
  type = string
  description = "Public IP for exposing VM to internet"
  default = ""
}

variable "service_account_email" {
    type = string
    description = "Service account for basic usage"
}

variable "scope" {
  type = string
  description = "Default scope for service accounts"
  default = "cloud-platform"
}
