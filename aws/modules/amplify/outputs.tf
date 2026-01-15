# ------------------------------------------------------------------------------
# AWS Amplify Module Outputs
# ------------------------------------------------------------------------------

output "app_id" {
  description = "ID of the Amplify app"
  value       = aws_amplify_app.main.id
}

output "app_arn" {
  description = "ARN of the Amplify app"
  value       = aws_amplify_app.main.arn
}

output "default_domain" {
  description = "Default domain for the Amplify app"
  value       = aws_amplify_app.main.default_domain
}

output "branch_name" {
  description = "Name of the deployed branch"
  value       = aws_amplify_branch.main.branch_name
}

output "branch_url" {
  description = "URL for the branch"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.main.default_domain}"
}

output "production_url" {
  description = "Production URL (if custom domain configured)"
  value       = var.domain_name != "" ? "https://${var.subdomain_prefix != "" ? "${var.subdomain_prefix}." : ""}${var.domain_name}" : null
}

output "webhook_url" {
  description = "Webhook URL for CI/CD triggers"
  value       = var.create_webhook ? aws_amplify_webhook.main[0].url : null
  sensitive   = true
}

output "custom_domain_arn" {
  description = "ARN of custom domain association"
  value       = var.domain_name != "" ? aws_amplify_domain_association.main[0].arn : null
}
