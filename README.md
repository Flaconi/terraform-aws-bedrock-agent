# terraform-aws-bedrock-agent

Terraform module for Amazon Bedrock Agent resources

[![lint](https://github.com/flaconi/terraform-aws-bedrock-agent/workflows/lint/badge.svg)](https://github.com/flaconi/terraform-aws-bedrock-agent/actions?query=workflow%3Alint)
[![test](https://github.com/flaconi/terraform-aws-bedrock-agent/workflows/test/badge.svg)](https://github.com/flaconi/terraform-aws-bedrock-agent/actions?query=workflow%3Atest)
[![Tag](https://img.shields.io/github/tag/flaconi/terraform-aws-bedrock-agent.svg)](https://github.com/flaconi/terraform-aws-bedrock-agent/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)


<!-- TFDOCS_HEADER_START -->


<!-- TFDOCS_HEADER_END -->

<!-- TFDOCS_PROVIDER_START -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.73 |
| <a name="provider_opensearch"></a> [opensearch](#provider\_opensearch) | ~> 2.2 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.12 |

<!-- TFDOCS_PROVIDER_END -->

<!-- TFDOCS_REQUIREMENTS_START -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.73 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | ~> 2.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

<!-- TFDOCS_REQUIREMENTS_END -->

<!-- TFDOCS_INPUTS_START -->
## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: Name for the agent.

Type: `string`

### <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name)

Description: Name for the agent alias.

Type: `string`

### <a name="input_agent_instructions"></a> [agent\_instructions](#input\_agent\_instructions)

Description: Model identifier for agent.

Type: `string`

### <a name="input_knowledgebase_name"></a> [knowledgebase\_name](#input\_knowledgebase\_name)

Description: Name for the knowledgebase.

Type: `string`

### <a name="input_knowledgebase_description"></a> [knowledgebase\_description](#input\_knowledgebase\_description)

Description: Description for the knowledgebase.

Type: `string`

### <a name="input_s3_configuration"></a> [s3\_configuration](#input\_s3\_configuration)

Description: ARN of S3 bucket with data

Type:

```hcl
object({
    bucket_arn              = string
    bucket_owner_account_id = optional(string)
    inclusion_prefixes      = optional(set(string))
  })
```

### <a name="input_oss_collection_name"></a> [oss\_collection\_name](#input\_oss\_collection\_name)

Description: Name of OpenSearch Serverless Collection.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_alias_description"></a> [alias\_description](#input\_alias\_description)

Description: Description for the agent alias.

Type: `string`

Default: `null`

### <a name="input_agent_model_id"></a> [agent\_model\_id](#input\_agent\_model\_id)

Description: Model identifier for agent.

Type: `string`

Default: `"anthropic.claude-v2"`

### <a name="input_knowledgebase_model_id"></a> [knowledgebase\_model\_id](#input\_knowledgebase\_model\_id)

Description: Model identifier for Knowledgebase.

Type: `string`

Default: `"amazon.titan-embed-text-v1"`

### <a name="input_knowledgebase_data_deletion_policy"></a> [knowledgebase\_data\_deletion\_policy](#input\_knowledgebase\_data\_deletion\_policy)

Description: Data deletion policy for a data source. Valid values: `RETAIN`, `DELETE`

Type: `string`

Default: `"RETAIN"`

### <a name="input_oss_additional_roles_arns"></a> [oss\_additional\_roles\_arns](#input\_oss\_additional\_roles\_arns)

Description: Additional ARNs of roles to access OpenSearch

Type: `list(string)`

Default: `[]`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to assign to the customization job and custom model.

Type: `map(string)`

Default: `{}`

<!-- TFDOCS_INPUTS_END -->

<!-- TFDOCS_OUTPUTS_START -->
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent"></a> [agent](#output\_agent) | Information about created Bedrock Agent |
| <a name="output_agent_alias"></a> [agent\_alias](#output\_agent\_alias) | Information about created Bedrock Agent Alias |
| <a name="output_knowledge_base"></a> [knowledge\_base](#output\_knowledge\_base) | Information about created Bedrock Knowledgebase |
| <a name="output_oss_collection"></a> [oss\_collection](#output\_oss\_collection) | Information about created OpenSearch Serverless collection |

<!-- TFDOCS_OUTPUTS_END -->

## License

**[MIT License](LICENSE)**

Copyright (c) 2024 **[Flaconi GmbH](https://github.com/flaconi)**
