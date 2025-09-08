# Example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agent"></a> [agent](#module\_agent) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_configuration"></a> [s3\_configuration](#input\_s3\_configuration) | ARN of S3 bucket with data | <pre>object({<br>    bucket_arn              = string<br>    bucket_owner_account_id = optional(string)<br>    inclusion_prefixes      = optional(set(string))<br>  })</pre> | n/a | yes |
| <a name="input_oss_additional_roles_arns"></a> [oss\_additional\_roles\_arns](#input\_oss\_additional\_roles\_arns) | Additional ARNs of roles to access OpenSearch | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resources"></a> [resources](#output\_resources) | Information about created resources |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
