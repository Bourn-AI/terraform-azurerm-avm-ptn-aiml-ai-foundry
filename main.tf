data "azurerm_client_config" "current" {}

resource "random_string" "resource_token" {
  length  = 5
  lower   = true
  numeric = true
  special = false
  upper   = false
}

locals {
  additional_storage_connections_resolved = {
    for project_key, project in var.ai_projects : project_key => {
      for connection_key, connection in lookup(project, "additional_storage_connections", {}) :
      connection_key => {
        resource_id   = lookup(connection, "use_existing", true) ? lookup(connection, "existing_resource_id", null) : try(module.storage_account_additional["${project_key}-${connection_key}"].resource_id, null)
        name_override = lookup(connection, "name_override", null)
      }
    }
  }

  additional_storage_connections_payload = {
    for project_key, connections in local.additional_storage_connections_resolved : project_key => {
      for connection_key, connection in connections :
      connection_key => {
        category  = "AzureStorageAccount"
        auth_type = "AAD"
        target    = "https://${basename(connection.resource_id)}.blob.core.windows.net/"
        metadata = {
          ApiType    = "Azure"
          ResourceId = connection.resource_id
          location   = local.location
        }
        name_override = connection.name_override
      } if connection.resource_id != null
    }
  }

  key_vault_ids_for_account = toset(compact([
    for _, project in var.ai_projects :
    try(coalesce(project.key_vault_connection.existing_resource_id, module.key_vault[project.key_vault_connection.new_resource_map_key].resource_id, null), null)
  ]))

  key_vault_connections_account = { for id in local.key_vault_ids_for_account : id => {
    resource_id = id
    name        = "kv-${basename(id)}"
  } }
}


module "ai_foundry_project" {
  source   = "./modules/ai-foundry-project"
  for_each = var.ai_projects

  ai_agent_host_name = local.resource_names.ai_agent_host
  ai_foundry_id      = azapi_resource.ai_foundry.id
  description        = each.value.description
  display_name       = each.value.display_name
  location           = local.location
  additional_connections = merge(
    try(each.value.additional_connections, {}),
    lookup(local.additional_storage_connections_payload, each.key, {})
  )
  additional_connections_key_vault = lookup(each.value, "additional_connections_key_vault", null)
  name                             = each.value.name
  #ai_search_id               = try(coalesce(each.value.ai_search_connection.existing_resource_id, try(module.ai_search[each.value.ai_search_connection.new_resource_map_key].resource_id, null)), null)
  ai_search_id               = try(coalesce(each.value.ai_search_connection.existing_resource_id, try(azapi_resource.ai_search[each.value.ai_search_connection.new_resource_map_key].id, null)), null)
  cosmos_db_id               = try(coalesce(each.value.cosmos_db_connection.existing_resource_id, try(module.cosmosdb[each.value.cosmos_db_connection.new_resource_map_key].resource_id, null)), null)
  create_ai_agent_service    = var.ai_foundry.create_ai_agent_service
  create_project_connections = each.value.create_project_connections
  storage_account_id         = try(coalesce(each.value.storage_account_connection.existing_resource_id, try(module.storage_account[each.value.storage_account_connection.new_resource_map_key].resource_id, null)), null)
  tags                       = var.tags

  depends_on = [
    azapi_resource.ai_foundry,
    azapi_resource.ai_agent_capability_host,
    azurerm_private_endpoint.ai_foundry,
    azapi_resource.ai_search,
    azurerm_private_endpoint.pe_aisearch, #module.ai_search,
    module.cosmosdb,
    module.key_vault,
    module.storage_account,
    azapi_resource.key_vault_connection_account
  ]
}

data "azurerm_key_vault" "account_connections" {
  for_each = local.key_vault_connections_account

  name                = basename(each.value.resource_id)
  resource_group_name = split("/", each.value.resource_id)[4]
}

resource "azapi_resource" "key_vault_connection_account" {
  for_each = local.key_vault_connections_account

  name      = each.value.name
  parent_id = azapi_resource.ai_foundry.id
  type      = "Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview"
  body = {
    properties = {
      category = "AzureKeyVault"
      target   = each.value.resource_id
      authType = "AccountManagedIdentity"
      metadata = {
        ApiType    = "Azure"
        ResourceId = each.value.resource_id
        location   = data.azurerm_key_vault.account_connections[each.key].location
      }
    }
  }
  schema_validation_enabled = false

  lifecycle {
    ignore_changes = [name]
  }
}
