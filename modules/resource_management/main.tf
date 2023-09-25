resource "google_folder" "folder" {
  display_name = var.folder_name
  parent       = try(var.folder_parent, null)
}

resource "google_project" "project" {
 
    for_each = {
    for index, i in local.projects :
      i.name => i
  }

  billing_account = var.billing_account
  name       = each.value.name
  project_id = lower(replace(each.value.name, " ", "-"))
  folder_id  = google_folder.folder.id
  auto_create_network = each.value.auto_create_network
  skip_delete         = each.value.skip_delete
}



resource "google_project_service" "services" {
  for_each   = local.services
  project    = each.value
  service    = replace(each.key, "/.*\\//", "")
}