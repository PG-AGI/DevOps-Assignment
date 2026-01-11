############################################################
# Backend Cloud Run Service
############################################################
resource "google_cloud_run_service" "backend" {
  name     = "backend-service"
  location = var.region

  template {
    spec {
      containers {
        image = var.backend_image

        env {
          name = "APP_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.backend_secret.secret_id
              key  = "latest"
            }
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_secret_manager_secret_version.backend_secret_version,
    google_secret_manager_secret_iam_member.cloudrun_access
  ]
}



# Public access to backend
resource "google_cloud_run_service_iam_member" "public_backend" {
  service  = google_cloud_run_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

############################################################
# Frontend Cloud Run Service
############################################################
resource "google_cloud_run_service" "frontend" {
  name     = "frontend-service"
  location = var.region

  template {
    spec {
      containers {
        image = var.frontend_image

        ports {
          container_port = 3000
        }

        env {
          name  = "NEXT_PUBLIC_API_URL"
          value = google_cloud_run_service.backend.status[0].url
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_cloud_run_service.backend
  ]
}

# Public access to frontend
resource "google_cloud_run_service_iam_member" "public_frontend" {
  service  = google_cloud_run_service.frontend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

