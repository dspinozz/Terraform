# ------------------------------------------------------------------------------
# Calculator App Outputs
# ------------------------------------------------------------------------------

output "app_id" {
  description = "Amplify app ID"
  value       = module.amplify.app_id
}

output "app_url" {
  description = "Default Amplify URL"
  value       = module.amplify.branch_url
}

output "default_domain" {
  description = "Default Amplify domain"
  value       = module.amplify.default_domain
}

output "production_url" {
  description = "Production URL (if custom domain configured)"
  value       = module.amplify.production_url
}
