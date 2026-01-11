resource "google_cloud_run_service" "frontend" {
  name     = "frontend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.frontend.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/frontend/frontend:${var.image_tag}"

        ports {
          container_port = 3000
        }

        env {
          name  = "NEXT_PUBLIC_API_URL"
          value = "/api"
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

resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_service.frontend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
