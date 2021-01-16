data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

