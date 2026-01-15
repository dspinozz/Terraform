# AWS Amplify Module

Creates an AWS Amplify app for hosting static sites or SSR applications with GitHub integration.

## Features

- GitHub repository integration
- Automatic builds on push
- Custom domain support
- Pull request previews
- SPA routing rules

## Usage

```hcl
module "amplify" {
  source = "../../modules/amplify"

  name           = "my-app"
  repository_url = "https://github.com/user/repo"
  branch_name    = "main"
  environment    = "dev"

  github_access_token = var.github_token

  build_output_directory = "dist"
  framework              = "React"

  environment_variables = {
    REACT_APP_API_URL = "https://api.example.com"
  }

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the Amplify app | string | - | yes |
| repository_url | GitHub repository URL | string | - | yes |
| github_access_token | GitHub personal access token | string | - | yes |
| branch_name | Branch to deploy | string | "main" | no |
| build_output_directory | Build output directory | string | "dist" | no |
| framework | Framework type | string | "React" | no |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Amplify app ID |
| default_domain | Default Amplify domain |
| branch_url | URL for the deployed branch |
