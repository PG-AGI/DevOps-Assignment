# ===================================================================
# GCP Cloud Run - Backend Service
# ===================================================================

resource "google_cloud_run_service" "backend" {
  name     = "${var.app_name}-backend-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/devops-backend:${var.environment}"
        
        resources {
          limits = {
            cpu    = var.backend_cpu
            memory = var.backend_memory
          }
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      }
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = string(var.backend_min_instances)
        "autoscaling.knative.dev/maxScale" = string(var.backend_max_instances)
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [template, traffic]
  }
}

# Backend Service IAM - Allow public access
data "google_iam_policy" "backend_noauth" {
  location    = google_cloud_run_service.backend.location
  namespace   = google_cloud_run_service.backend.namespace
  project     = google_cloud_run_service.backend.project

  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "backend_noauth" {
  location    = google_cloud_run_service.backend.location
  project     = google_cloud_run_service.backend.project
  service     = google_cloud_run_service.backend.name
  policy_data = data.google_iam_policy.backend_noauth.policy_data
}

# ===================================================================
# GCP Cloud Run - Frontend Service
# ===================================================================

resource "google_cloud_run_service" "frontend" {
  name     = "${var.app_name}-frontend-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/devops-frontend:${var.environment}"
        
        resources {
          limits = {
            cpu    = var.frontend_cpu
            memory = var.frontend_memory
          }
        }
        
        env {
          name  = "NEXT_PUBLIC_API_URL"
          value = google_cloud_run_service.backend.status[0].url
        }
      }
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = string(var.frontend_min_instances)
        "autoscaling.knative.dev/maxScale" = string(var.frontend_max_instances)
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [template, traffic]
  }
}

# Frontend Service IAM - Allow public access
data "google_iam_policy" "frontend_noauth" {
  location    = google_cloud_run_service.frontend.location
  namespace   = google_cloud_run_service.frontend.namespace
  project     = google_cloud_run_service.frontend.project

  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "frontend_noauth" {
  location    = google_cloud_run_service.frontend.location
  project     = google_cloud_run_service.frontend.project
  service     = google_cloud_run_service.frontend.name
  policy_data = data.google_iam_policy.frontend_noauth.policy_data
}

# ===================================================================
# Outputs
# ===================================================================

output "backend_url" {
  description = "Backend Cloud Run service URL"
  value       = google_cloud_run_service.backend.status[0].url
}

output "frontend_url" {
  description = "Frontend Cloud Run service URL"
  value       = google_cloud_run_service.frontend.status[0].url
}

output "backend_service_account" {
  description = "Backend service account email"
  value       = google_cloud_run_service.backend.template[0].spec[0].service_account_name
}
