variable project_id {
  default = "todo-er"
}
variable "instance_zone" {}
variable "instance_type" {}
variable "instance_network" {}
variable "instance_name" {}
variable "instance_image" {}
variable "instance_subnet" {}
variable "startup_file" {}
variable "instance_ip" {}

resource "google_compute_instance" "vm_instance" {
  project      = var.project_id
  name         = var.instance_name
  zone         = var.instance_zone
  machine_type = var.instance_type
  metadata_startup_script = file(var.startup_file)
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = var.instance_network
    subnetwork = var.instance_subnet
    network_ip = var.instance_ip
    access_config {
   
    }
  }
}

output "external_ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
