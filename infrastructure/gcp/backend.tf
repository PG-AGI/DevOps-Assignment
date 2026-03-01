terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

# State management - GCS with versioning
terraform {
  backend "gcs" {
    bucket = "devops-assignment-tf-state"
    prefix = "gcp/${var.environment}"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  
  default_labels = {
    project     = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
