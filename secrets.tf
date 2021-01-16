resource "google_secret_manager_secret" "secret_variables" {
  secret_id = "secret_variables"
  project   = data.google_project.project.number

  replication {
    automatic = true
  }
}
