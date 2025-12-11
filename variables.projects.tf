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
    additional_connections = optional(map(object({
      category      = string
      target        = string
      auth_type     = string
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
  - `additional_connections` - (Optional) Map of additional project connections to create using the AI Foundry connections API (e.g., API Key, Custom Keys, SharePoint). Each map value supports:
    - `category` - (Required) Connection category (see AI Foundry docs).
    - `target` - (Required) Target endpoint URL.
    - `auth_type` - (Required) Authentication type for the connection.
    - `metadata` - (Optional) Key/value metadata for the connection.
    - `credentials` - (Optional) Key/value secret material (marked sensitive upstream).
    - `key_vault_secret` - (Optional) Source credentials from Key Vault instead of inline secrets. Provide vault name, resource group, and secret name; `credential_key` sets the key name in the credentials object (default "key").
    - `name_override` - (Optional) Explicit connection name; defaults to the map key.
DESCRIPTION
}
