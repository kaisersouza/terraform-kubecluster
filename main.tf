provider "google" {
  credentials = file("key.json")
  project     = "projectborealis"
  region      = "europe-west3"
}

resource "google_compute_subnetwork" "rsubnet1" {
  name          = "rsubnet1"
  ip_cidr_range = "10.10.10.0/24"
  region        = "europe-west3"
  network       = google_compute_network.rnet1.id
}

resource "google_compute_network" "rnet1" {
  name                    = "rnet1"
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "kube-fw" {
  name    = "kube-fw"
  network = google_compute_network.rnet1.name
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "1723", "6443", "10250", "10259", "10257", "2379-2380", "30000-32767"]
  }

}

resource "google_compute_instance" "master" {
  name         =   "master"
  machine_type = "n2-standard-2"
  zone         = "europe-west3-a"
  boot_disk {
    initialize_params {
      type  = "pd-ssd"
      image = "debian-cloud/debian-10"
      size = "35"
    }
  }
  depends_on = [google_compute_subnetwork.rsubnet1]
  network_interface {
    network = "rnet1"
    subnetwork = "rsubnet1"
    network_ip = "10.10.10.10"
    access_config {}
  }
}

 resource "google_compute_instance" "worker1" {
   name         =   "worker1"
   machine_type = "n2-standard-2"
   zone         = "europe-west3-b"
   boot_disk {
     initialize_params {
       type  = "pd-ssd"
       image = "debian-cloud/debian-10"
       size = "35"
     }
   }
   depends_on = [google_compute_subnetwork.rsubnet1]
   network_interface {
     network = "rnet1"
     subnetwork = "rsubnet1"
     network_ip = "10.10.10.20"
     access_config {}
   }
  }
