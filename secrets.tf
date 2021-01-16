locals {
  secret_variables = jsondecode(data.google_secret_manager_secret_version.secret_variables.secret_data)
}

data "google_secret_manager_secret_version" "secret_variables" {
  provider = google-beta

  project = data.google_project.project.number
  secret  = google_secret_manager_secret.secret_variables.secret_id
  version = 1 # valid json
}

resource "google_secret_manager_secret" "secret_variables" {
  secret_id = "secret_variables"
  project   = data.google_project.project.number

  replication {
    automatic = true
  }
}
