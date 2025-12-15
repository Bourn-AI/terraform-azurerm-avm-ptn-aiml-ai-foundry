variable "ai_agent_host_name" {
  type        = string
  description = "Name of the AI agent capability host"
}

variable "ai_foundry_id" {
  type        = string
  description = "Resource ID of the AI Foundry account"
}

variable "description" {
  type        = string
  description = "Description for the AI Foundry project"
}

variable "display_name" {
  type        = string
  description = "Display name for the AI Foundry project"
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
  nullable    = false
}

variable "name" {
  type        = string
  description = "Name of the AI Foundry project"
}

variable "ai_search_id" {
  type        = string
  default     = null
  description = "Resource ID of the AI Search service"
}

variable "cosmos_db_id" {
  type        = string
  default     = null
  description = "Resource ID of the Cosmos DB account"
}

variable "create_ai_agent_service" {
  type        = bool
  default     = true
  description = "Whether to create the AI agent service"
}

variable "create_project_connections" {
  type        = bool
  default     = false
  description = "Whether to create project connections for AI Foundry, Cosmos DB, Key Vault, and AI Search. If set to false, the project will not create connections to these resources."
}

variable "additional_connections" {
  description = "Additional AI Foundry project connections to create beyond the built-in Cosmos DB, AI Search, and Storage connections. For CustomKeys auth types, credentials (including Key Vault values) are placed under credentials.keys per the connections schema. When key_vault_secret is provided, values in credentials are treated as secret names in that vault."
  type = map(object({
    category                  = string
    target                    = string
    auth_type                 = string
    metadata                  = optional(map(string), {})
    credentials               = optional(map(string))
    name_override             = optional(string)
    api_version               = optional(string, "2025-04-01-preview")
    schema_validation_enabled = optional(bool, false)
    key_vault_secret = optional(object({
      key_vault_name      = string
      resource_group_name = string
      secret_name         = string
      secret_version      = optional(string)
      credential_key      = optional(string, "key")
    }))
  }))
  default = {}
}

variable "additional_connections_key_vault" {
  description = "Optional shared Key Vault for resolving credentials in additional_connections when a per-connection key_vault_secret is not provided. When set, every value in an additional_connections.credentials map is treated as a secret name in this vault."
  type = object({
    key_vault_name      = string
    resource_group_name = string
    secret_version      = optional(string)
  })
  default = null
}

variable "sku" {
  type        = string
  default     = "S0"
  description = "SKU for the AI Foundry project"
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Resource ID of the Storage Account"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to apply to resources"
}
