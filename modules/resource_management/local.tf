locals {
  workloads = yamldecode(file("${path.root}/workloads.yml"))
  projects = flatten([ for v in local.workloads : [ for project in v.projects : { name = project.name, auto_create_network = project.auto_create_network, services = project.services  } ] ]) 
  # Creates a map of apis and project { project/api => project }
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
