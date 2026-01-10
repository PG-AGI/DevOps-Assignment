resource "google_cloud_run_service" "frontend" {
  name     = "frontend-service"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = var.frontend_image

        ports {
          container_port = 3000
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.frontend.name
  location = google_cloud_run_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

