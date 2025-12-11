locals {
  foundry_default_role_assignments = {
    #holding this variable in the event we need to add static defaults in the future.
  }
  foundry_role_assignments = merge(
    local.foundry_default_role_assignments,
    var.ai_foundry.role_assignments
  )
  role_definition_resource_substring = "providers/Microsoft.Authorization/roleDefinitions"

  foundry_key_vault_default_role_assignments = {
    key_vault_secrets_officer = {
      name                       = "kv-secrets-officer"
      role_definition_id_or_name = "Key Vault Secrets Officer"
    }
  }
}
