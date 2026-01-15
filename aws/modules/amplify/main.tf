# ------------------------------------------------------------------------------
# AWS Amplify Module
# Creates an Amplify app for hosting static sites or SSR applications
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Amplify App
# ------------------------------------------------------------------------------

resource "aws_amplify_app" "main" {
  name       = var.name
  repository = var.repository_url

  # OAuth token for GitHub access
  access_token = var.github_access_token

  # Build settings
  build_spec = var.build_spec != "" ? var.build_spec : <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: ${var.build_output_directory}
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # Environment variables (set at app level)
  environment_variables = var.environment_variables

  # Custom rules (redirects/rewrites)
  dynamic "custom_rule" {
    for_each = var.custom_rules
    content {
      source    = custom_rule.value.source
      target    = custom_rule.value.target
      status    = custom_rule.value.status
      condition = lookup(custom_rule.value, "condition", null)
    }
  }

  # Platform configuration
  platform = var.platform

  # Auto branch creation
  enable_auto_branch_creation   = var.enable_auto_branch_creation
  enable_branch_auto_build      = var.enable_branch_auto_build
  enable_branch_auto_deletion   = var.enable_branch_auto_deletion
  
  auto_branch_creation_patterns = var.auto_branch_creation_patterns

  dynamic "auto_branch_creation_config" {
    for_each = var.enable_auto_branch_creation ? [1] : []
    content {
      enable_auto_build           = true
      enable_pull_request_preview = var.enable_pull_request_preview
      framework                   = var.framework
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Branch
# ------------------------------------------------------------------------------

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.main.id
  branch_name = var.branch_name

  framework = var.framework
  stage     = var.environment == "prod" ? "PRODUCTION" : "DEVELOPMENT"

  enable_auto_build             = var.enable_auto_build
  enable_pull_request_preview   = var.enable_pull_request_preview
  enable_notification           = var.enable_notifications

  environment_variables = var.branch_environment_variables

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Domain Association (optional)
# ------------------------------------------------------------------------------

resource "aws_amplify_domain_association" "main" {
  count = var.domain_name != "" ? 1 : 0

  app_id      = aws_amplify_app.main.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = var.subdomain_prefix
  }

  dynamic "sub_domain" {
    for_each = var.additional_subdomains
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.prefix
    }
  }

  wait_for_verification = var.wait_for_verification
}

# ------------------------------------------------------------------------------
# Webhook (for CI/CD triggers)
# ------------------------------------------------------------------------------

resource "aws_amplify_webhook" "main" {
  count = var.create_webhook ? 1 : 0

  app_id      = aws_amplify_app.main.id
  branch_name = aws_amplify_branch.main.branch_name
  description = "Webhook for ${var.name} - ${var.branch_name}"
}
