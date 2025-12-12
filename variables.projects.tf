variable "ai_projects" {
  type = map(object({
    name                       = string
    sku                        = optional(string, "S0")
    display_name               = string
    description                = string
    create_project_connections = optional(bool, false)
    cosmos_db_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    ai_search_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    key_vault_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    storage_account_connection = optional(object({
      existing_resource_id = optional(string, null)
      new_resource_map_key = optional(string, null)
    }), {})
    additional_storage_connections = optional(map(object({
      use_existing         = optional(bool, true)
      existing_resource_id = optional(string, null)
      name_override        = optional(string, null)
      # When use_existing is false, provide new_storage_account details mirroring storage_account_definition
      new_storage_account = optional(object({
        enable_diagnostic_settings = optional(bool, true)
        name                       = optional(string, null)
        account_kind               = optional(string, "StorageV2")
        account_tier               = optional(string, "Standard")
        account_replication_type   = optional(string, "ZRS")
        endpoints = optional(map(object({
          type                         = string
          private_dns_zone_resource_id = optional(string, null)
          })), {
          blob = {
            type = "blob"
          }
        })
        access_tier               = optional(string, "Hot")
        shared_access_key_enabled = optional(bool, false)
        role_assignments = optional(map(object({
          role_definition_id_or_name             = string
          principal_id                           = string
          description                            = optional(string, null)
          skip_service_principal_aad_check       = optional(bool, false)
          condition                              = optional(string, null)
          condition_version                      = optional(string, null)
          delegated_managed_identity_resource_id = optional(string, null)
          principal_type                         = optional(string, null)
        })), {})
        tags = optional(map(string), {})
      }), null)
    })), {})
    additional_connections = optional(map(object({
      category      = string
      target        = optional(string, "_")
      auth_type     = string
      api_version   = optional(string, "2025-10-01-preview")
      metadata      = optional(map(string), {})
      credentials   = optional(map(string))
      name_override = optional(string)
      key_vault_secret = optional(object({
        key_vault_name      = string
        resource_group_name = string
        secret_name         = string
        secret_version      = optional(string)
        credential_key      = optional(string, "key")
      }))
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Configuration map for AI Foundry projects to be created. Each project can have its own settings and connections to dependent resources.

- `map key` - The key for the map entry. This key should match the dependent resources keys when creating connections.
  - `name` - The name of the AI Foundry project.
  - `sku` - (Optional) The SKU of the AI Foundry project. Default is "S0".
  - `display_name` - The display name of the AI Foundry project.
  - `description` - The description of the AI Foundry project.
  - `create_project_connections` - (Optional) Whether to create connections to dependent resources. Default is false.
  - `cosmos_db_connection` - (Optional) Configuration for Cosmos DB connection.
    - `existing_resource_id` - (Optional) The resource ID of an existing Cosmos DB account to connect to.
    - `new_resource_map_key` - (Optional) The map key of a new Cosmos DB account to be created and connected.
  - `ai_search_connection` - (Optional) Configuration for AI Search connection.
    - `existing_resource_id` - (Optional) The resource ID of an existing AI Search service to connect to.
    - `new_resource_map_key` - (Optional) The map key of a new AI Search service to be created and connected.
  - `key_vault_connection` - (Optional) Configuration for Key Vault connection.
    - `existing_resource_id` - (Optional) The resource ID of an existing Key Vault to connect to.
    - `new_resource_map_key` - (Optional) The map key of a new Key Vault to be created and connected.
  - `storage_account_connection` - (Optional) Configuration for Storage Account connection.
    - `existing_resource_id` - (Optional) The resource ID of an existing Storage Account to connect to.
    - `new_resource_map_key` - (Optional) The map key of a new Storage Account to be created and connected.
  - `additional_storage_connections` - (Optional) Map of additional storage connections. Each entry can either use an existing storage account or create a new one (same shape as `storage_account_definition`):
    - `use_existing` - (Optional) Whether to use an existing storage account. Default is true.
    - `existing_resource_id` - (Optional) Resource ID of an existing storage account (required if `use_existing` is true).
    - `name_override` - (Optional) Explicit connection name; defaults to the map key.
    - `new_storage_account` - (Optional) Settings to create a new storage account when `use_existing` is false. Mirrors `storage_account_definition` (name, SKU, replication, endpoints, access tier, shared access keys, role assignments, tags, diagnostic settings).
  - `additional_connections` - (Optional) Map of additional project connections to create using the AI Foundry connections API (e.g., API Key, Custom Keys, SharePoint). Each map value supports:
    - `category` - (Required) Connection category (see AI Foundry docs).
    - `target` - (Optional) Target endpoint URL.
    - `auth_type` - (Required) Authentication type for the connection.
    - `metadata` - (Optional) Key/value metadata for the connection.
    - `credentials` - (Optional) Key/value secret material (marked sensitive upstream).
    - `key_vault_secret` - (Optional) Source credentials from Key Vault instead of inline secrets. Provide vault name, resource group, and secret name; `credential_key` sets the key name in the credentials object (default "key").
    - `name_override` - (Optional) Explicit connection name; defaults to the map key.
DESCRIPTION
}
