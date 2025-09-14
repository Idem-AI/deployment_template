resource "google_service_account" "shared_sa" {
  account_id   = "${var.deployment_name}-shared-sa"
  display_name = "Service Account for all GCP services"
  project      = var.project_id
}

resource "google_project_iam_member" "shared_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.shared_sa.email}"
}
