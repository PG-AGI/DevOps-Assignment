############################################################
# Enable Secret Manager API
############################################################
resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

############################################################
# Create Secret
############################################################
resource "google_secret_manager_secret" "backend_secret" {
  project   = var.project_id
  secret_id = "backend-secret-key"

  replication {
    auto {}
  }
}

############################################################
# Create Secret Version
############################################################
resource "google_secret_manager_secret_version" "backend_secret_version" {
  secret      = google_secret_manager_secret.backend_secret.id
  secret_data = var.backend_secret_value
}
############################################################
# Allow Cloud Run to access Secret
############################################################
resource "google_secret_manager_secret_iam_member" "cloudrun_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.backend_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}
