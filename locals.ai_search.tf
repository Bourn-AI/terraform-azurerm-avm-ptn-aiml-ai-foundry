locals {
  # AI Search instances that get a private endpoint (have DNS zone and PE creation is enabled).
  # When private_dns_zone_resource_id is null/empty, no PE is created and AI Search stays public.
  ai_search_with_pe = {
    for k, v in var.ai_search_definition : k => v
    if v.existing_resource_id == null && var.create_byor == true && var.create_private_endpoints == true && try(v.private_dns_zone_resource_id, null) != null && v.private_dns_zone_resource_id != ""
  }

  ai_search_rbac = { for role in flatten([
    for ak, av in var.ai_search_definition : [
      for rk, rv in av.role_assignments : {
        ai_key          = ak
        rbac_key        = rk
        role_assignment = rv
      }
    ]
  ]) : "${role.ai_key}-${role.rbac_key}" => role }
}
