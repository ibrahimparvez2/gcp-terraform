locals {
  workloads = yamldecode(file("${path.root}/workloads.yml"))
  projects = flatten([ for v in local.workloads : [ for project in v.projects : { name = project.name, auto_create_network = project.auto_create_network, services = project.services  } ] ]) 
  services = zipmap(
  flatten(
    [
      for projects_k, projects_v in local.projects :
      [
        for services_k, services_v in lookup(projects_v, "services", []) : "${projects_v.name}/${services_v}"
      ]
    ]
  ),
  flatten(
    [
      for projects_k, projects_v in local.projects :
      [
        for _, _ in lookup(projects_v, "services", []) : projects_v.name
      ]
    ]
  )
)
}

module "wwc_org" {
  source   = "../modules/resource_management"
  for_each = local.workloads

  billing_account = var.billing_account
  folder_parent   = var.folder_parent
  folder_name     = each.key

}
