############################################################
# Cloud Run Backend Service
############################################################
resource "google_cloud_run_service" "backend" {
  name     = "backend-service"
  location = var.region

  template {
    spec {
      containers {
        image = var.backend_image
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow public access to backend
resource "google_cloud_run_service_iam_member" "public_backend" {
  service  = google_cloud_run_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

############################################################
# Cloud Run Frontend Service
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

        # Pass backend URL as environment variable
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

  depends_on = [google_cloud_run_service.backend]
}

# Allow public access to frontend
resource "google_cloud_run_service_iam_member" "public_frontend" {
  service  = google_cloud_run_service.frontend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

