variable project_id {
  default = "todo-er"
}

variable "subnet_region" {
  default = "europe-west1"
}

resource "google_compute_network" "puppet-course-net" {
  project                 = var.project_id
  name                    = "puppet-course-net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-europe-west1" {
  project       = var.project_id
  name          = "subnet-europe-west1"
  network       = google_compute_network.puppet-course-net.self_link
  ip_cidr_range = "10.20.0.0/16"
  region        = var.subnet_region
}

resource "google_compute_firewall" "puppet-course-firwall" {
  project = var.project_id
  name    = "puppet-course-firewall"
  network = google_compute_network.puppet-course-net.self_link
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "3001", 8140]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_address" "master-ip-address" {
  name         = "master-ip-address"
  address_type = "INTERNAL"
  address      = "10.20.0.2"
  region       = var.subnet_region
  subnetwork      = google_compute_subnetwork.subnet-europe-west1.id
}

resource "google_compute_address" "centos-ip-address" {
 name         = "centos-ip-address" 
 address_type = "INTERNAL"
 address      = "10.20.0.4"
 region       = var.subnet_region
 subnetwork      = google_compute_subnetwork.subnet-europe-west1.id
}

resource "google_compute_address" "ubuntu-ip-address" {
  name         = "ubuntu-ip-address"
  address_type = "INTERNAL"
  address      = "10.20.0.3"
  region       = var.subnet_region
  subnetwork      = google_compute_subnetwork.subnet-europe-west1.id
}

module "puppet-master" {
  source           = "./instance"
  instance_name    = "puppet"
  instance_type    = "n1-standard-1"
  instance_image   = "centos-cloud/centos-8"
  instance_zone    = "europe-west1-d"
  startup_file     = "master-startup.sh"
  instance_ip 	   = google_compute_address.master-ip-address.address 
  instance_network = google_compute_network.puppet-course-net.self_link
  instance_subnet  = google_compute_subnetwork.subnet-europe-west1.self_link
}

module "puppet-host-centos" {
  source           = "./instance"
  instance_name    = "puppet-host-centos"
  instance_type    = "n1-standard-1"
  instance_image   = "centos-cloud/centos-8"
  instance_zone    = "europe-west1-d"
  instance_ip      = google_compute_address.centos-ip-address.address 
  startup_file     = "agent-centos-startup.sh"
  instance_network = google_compute_network.puppet-course-net.self_link
  instance_subnet  = google_compute_subnetwork.subnet-europe-west1.self_link
}

module "puppet-host-ubuntu" {
  source           = "./instance"
  instance_name    = "puppet-host-ubuntu"
  instance_type    = "n1-standard-1"
  instance_image   = "ubuntu-os-cloud/ubuntu-1804-lts"
  instance_zone    = "europe-west1-d"
  instance_ip      = google_compute_address.ubuntu-ip-address.address  
  startup_file     = "agent-ubuntu-startup.sh"
  instance_network = google_compute_network.puppet-course-net.self_link
  instance_subnet  = google_compute_subnetwork.subnet-europe-west1.self_link
}
