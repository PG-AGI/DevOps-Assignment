output "frontend_url" {
  value = google_cloud_run_service.frontend.status[0].url
}

