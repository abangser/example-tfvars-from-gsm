terraform {
  required_providers {
    google = {
      source      = "hashicorp/google"
      version     = "3.52.0"
    }
  }

  required_version = "~> 0.14"
}

provider "google" {
  project     = var.google_provider_vars.core_project_id
  credentials = file(var.google_provider_vars.credential_path)
}

provider "google-beta" {
  project     = var.google_provider_vars.core_project_id
  credentials = file(var.google_provider_vars.credential_path)
}
