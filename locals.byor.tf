
locals {
  cosmosdb_secondary_regions = { for k, v in var.cosmosdb_definition : k => (var.cosmosdb_definition[k].secondary_regions == null ? [] : (
    try(length(var.cosmosdb_definition[k].secondary_regions) == 0, false) ? [
      {
        location          = local.paired_region
        zone_redundant    = false #length(local.paired_region_zones) > 1 ? true : false TODO: set this back to dynamic based on region zone availability after testing. Our subs don't have quota for zonal deployments.
        failover_priority = 1
      },
      {
        location          = var.location
        zone_redundant    = false #length(local.region_zones) > 1 ? true : false
        failover_priority = 0
      }
    ] : var.cosmosdb_definition[k].secondary_regions)
  ) }
  #################################################################
  # Key Vault specific local variables
  #################################################################
  key_vault_default_role_assignments = {
    #holding this variable in the event we need to add static defaults in the future.
  }
  key_vault_role_assignments = { for k, v in var.key_vault_definition : k => merge(
    local.key_vault_default_role_assignments,
    var.key_vault_definition[k].role_assignments
  ) }
  #################################################################
  # Log Analytics specific local variables
  #################################################################
  log_analytics_workspace_name = length(var.law_definition) > 0 ? try(values(var.law_definition)[0].name, null) != null ? values(var.law_definition)[0].name : (try(var.base_name, null) != null ? "${var.base_name}-law" : "ai-foundry-law") : "ai-foundry-law"
  paired_region                = [for region in module.avm_utl_regions.regions : region if(lower(region.name) == lower(var.location) || (lower(region.display_name) == lower(var.location)))][0].paired_region_name
  resource_group_name          = basename(var.resource_group_resource_id) #assumes resource group id is required.
  storage_account_default_role_assignments = {
    #holding this variable in the event we need to add static defaults in the future.
  }
  #################################################################
  # Storage Account specific local variables
  #################################################################
  storage_account_role_assignments = { for k, v in var.storage_account_definition : k => merge(
    local.storage_account_default_role_assignments,
    var.storage_account_definition[k].role_assignments
  ) }

  #################################################################
  # Additional storage accounts for per-project storage connections
  #################################################################
  additional_storage_accounts_list = flatten([
    for project_key, project in var.ai_projects : [
      for connection_key, connection in lookup(project, "additional_storage_connections", {}) : {
        key                  = "${project_key}-${connection_key}"
        project_key          = project_key
        connection_key       = connection_key
        name_override        = lookup(connection, "name_override", null)
        use_existing         = lookup(connection, "use_existing", true)
        existing_resource_id = lookup(connection, "existing_resource_id", null)
        new_storage_account  = lookup(connection, "new_storage_account", null)
      } if lookup(connection, "use_existing", true) == false
    ]
  ])

  additional_storage_accounts = { for item in local.additional_storage_accounts_list : item.key => item }

  additional_storage_account_role_assignments = {
    for key, item in local.additional_storage_accounts :
    key => merge(local.storage_account_default_role_assignments, lookup(item.new_storage_account, "role_assignments", {}))
  }
}
