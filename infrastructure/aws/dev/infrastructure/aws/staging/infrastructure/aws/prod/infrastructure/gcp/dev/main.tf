provider "google" {
  region = "asia-south1"
}

resource "google_compute_instance" "dev_vm" {
  name         = "dev-vm"
  machine_type = "e2-micro"
  zone         = "asia-south1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
