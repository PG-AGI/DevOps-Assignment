resource "google_service_account" "backend" {
  account_id   = "cloudrun-backend-sa"
  display_name = "Cloud Run Backend SA"
}

resource "google_service_account" "frontend" {
  account_id   = "cloudrun-frontend-sa"
  display_name = "Cloud Run Frontend SA"
}

resource "google_project_iam_member" "backend_artifact" {
    project = var.project_id
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_project_iam_member" "backend_secrets" {
    project = var.project_id
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_project_iam_member" "frontend_artifact" {
    project = var.project_id
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.frontend.email}"
}
