resource "google_cloud_run_service" "backend" {
  name     = "backend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.backend.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/backend/backend:${var.image_tag}"

        ports {
          container_port = 8000
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "backend_public" {
  service  = google_cloud_run_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
