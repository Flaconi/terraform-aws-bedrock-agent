# terraform-aws-bedrock-agent

Terraform module for Amazon Bedrock Agent resources

[![lint](https://github.com/flaconi/terraform-aws-bedrock-agent/workflows/lint/badge.svg)](https://github.com/flaconi/terraform-aws-bedrock-agent/actions?query=workflow%3Alint)
[![test](https://github.com/flaconi/terraform-aws-bedrock-agent/workflows/test/badge.svg)](https://github.com/flaconi/terraform-aws-bedrock-agent/actions?query=workflow%3Atest)
[![Tag](https://img.shields.io/github/tag/flaconi/terraform-aws-bedrock-agent.svg)](https://github.com/flaconi/terraform-aws-bedrock-agent/releases)
[![Terraform](https://img.shields.io/badge/Terraform--registry-aws--bedrock--agent-brightgreen.svg)](https://registry.terraform.io/modules/flaconi/bedrock-agent/aws/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)


<!-- TFDOCS_HEADER_START -->


<!-- TFDOCS_HEADER_END -->

<!-- TFDOCS_PROVIDER_START -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_opensearch"></a> [opensearch](#provider\_opensearch) | ~> 2.3 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.13 |

<!-- TFDOCS_PROVIDER_END -->

<!-- TFDOCS_REQUIREMENTS_START -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | ~> 2.3 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13 |

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

### <a name="input_vector_ingestion_configuration"></a> [vector\_ingestion\_configuration](#input\_vector\_ingestion\_configuration)

Description: n/a

Type:

```hcl
object({
    chunking_configuration = object({
      chunking_strategy = string
      fixed_size_chunking_configuration = optional(object({
        max_tokens         = number
        overlap_percentage = optional(number)
      }))
      hierarchical_chunking_configuration = optional(object({
        overlap_tokens = number
        level_1        = object({ max_tokens = number })
        level_2        = object({ max_tokens = number })
      }))
      semantic_chunking_configuration = optional(object({
        breakpoint_percentile_threshold = number
        buffer_size                     = number
        max_token                       = number
      }))
    })
    custom_transformation_configuration = optional(object({
      intermediate_storage    = string
      transformation_function = string
    }))
  })
```

Default:

```json
{
  "chunking_configuration": {
    "chunking_strategy": "FIXED_SIZE",
    "fixed_size_chunking_configuration": {
      "max_tokens": 300,
      "overlap_percentage": 20
    },
    "hierarchical_chunking_configuration": null,
    "semantic_chunking_configuration": null
  }
}
```

### <a name="input_oss_additional_roles_arns"></a> [oss\_additional\_roles\_arns](#input\_oss\_additional\_roles\_arns)

Description: Additional ARNs of roles to access OpenSearch

Type: `list(string)`

Default: `[]`

### <a name="input_knowledge_base_response_generation_prompt_template"></a> [knowledge\_base\_response\_generation\_prompt\_template](#input\_knowledge\_base\_response\_generation\_prompt\_template)

Description: Prompt template for pre-processing.

Type: `string`

Default: `"        You are a helpful assistant. Answer the following question using the context provided:\n        Question: {question}\n        Context: {context}\n        Your response should be thoughtful, detailed, and relevant to the provided context.\n"`

### <a name="input_knowledge_base_response_generation_parser_mode"></a> [knowledge\_base\_response\_generation\_parser\_mode](#input\_knowledge\_base\_response\_generation\_parser\_mode)

Description: Parser mode for pre-processing.

Type: `string`

Default: `"DEFAULT"`

### <a name="input_knowledge_base_response_generation_prompt_creation_mode"></a> [knowledge\_base\_response\_generation\_prompt\_creation\_mode](#input\_knowledge\_base\_response\_generation\_prompt\_creation\_mode)

Description: Prompt creation mode for pre-processing.

Type: `string`

Default: `"OVERRIDDEN"`

### <a name="input_knowledge_base_response_generation_prompt_state"></a> [knowledge\_base\_response\_generation\_prompt\_state](#input\_knowledge\_base\_response\_generation\_prompt\_state)

Description: Prompt state for pre-processing.

Type: `string`

Default: `"ENABLED"`

### <a name="input_knowledge_base_response_generation_max_length"></a> [knowledge\_base\_response\_generation\_max\_length](#input\_knowledge\_base\_response\_generation\_max\_length)

Description: Maximum number of tokens to allow in the generated response.

Type: `number`

Default: `512`

### <a name="input_knowledge_base_response_generation_stop_sequences"></a> [knowledge\_base\_response\_generation\_stop\_sequences](#input\_knowledge\_base\_response\_generation\_stop\_sequences)

Description: List of stop sequences that will stop generation.

Type: `list(string)`

Default:

```json
[
  "END"
]
```

### <a name="input_knowledge_base_response_generation_temperature"></a> [knowledge\_base\_response\_generation\_temperature](#input\_knowledge\_base\_response\_generation\_temperature)

Description: Likelihood of the model selecting higher-probability options while generating a response.

Type: `number`

Default: `0.7`

### <a name="input_knowledge_base_response_generation_top_k"></a> [knowledge\_base\_response\_generation\_top\_k](#input\_knowledge\_base\_response\_generation\_top\_k)

Description: Number of top most-likely candidates from which the model chooses the next token.

Type: `number`

Default: `50`

### <a name="input_knowledge_base_response_generation_top_p"></a> [knowledge\_base\_response\_generation\_top\_p](#input\_knowledge\_base\_response\_generation\_top\_p)

Description: Top percentage of the probability distribution of next tokens, from which the model chooses the next token.

Type: `number`

Default: `0.9`

### <a name="input_pre_processing_prompt_template"></a> [pre\_processing\_prompt\_template](#input\_pre\_processing\_prompt\_template)

Description: Prompt template for pre-processing.

Type: `string`

Default: `"        You are preparing the input. Extract relevant context and pre-process the following question:\n        Question: {question}\n        Context: {context}\n        Pre-processing should focus on extracting the core information.\n"`

### <a name="input_pre_processing_parser_mode"></a> [pre\_processing\_parser\_mode](#input\_pre\_processing\_parser\_mode)

Description: Parser mode for pre-processing.

Type: `string`

Default: `"DEFAULT"`

### <a name="input_pre_processing_prompt_creation_mode"></a> [pre\_processing\_prompt\_creation\_mode](#input\_pre\_processing\_prompt\_creation\_mode)

Description: Prompt creation mode for pre-processing.

Type: `string`

Default: `"OVERRIDDEN"`

### <a name="input_pre_processing_prompt_state"></a> [pre\_processing\_prompt\_state](#input\_pre\_processing\_prompt\_state)

Description: Prompt state for pre-processing.

Type: `string`

Default: `"ENABLED"`

### <a name="input_pre_processing_max_length"></a> [pre\_processing\_max\_length](#input\_pre\_processing\_max\_length)

Description: Maximum number of tokens to allow in the generated response.

Type: `number`

Default: `512`

### <a name="input_pre_processing_stop_sequences"></a> [pre\_processing\_stop\_sequences](#input\_pre\_processing\_stop\_sequences)

Description: List of stop sequences that will stop generation.

Type: `list(string)`

Default:

```json
[
  "END"
]
```

### <a name="input_pre_processing_temperature"></a> [pre\_processing\_temperature](#input\_pre\_processing\_temperature)

Description: Likelihood of the model selecting higher-probability options while generating a response.

Type: `number`

Default: `0.7`

### <a name="input_pre_processing_top_k"></a> [pre\_processing\_top\_k](#input\_pre\_processing\_top\_k)

Description: Number of top most-likely candidates from which the model chooses the next token.

Type: `number`

Default: `50`

### <a name="input_pre_processing_top_p"></a> [pre\_processing\_top\_p](#input\_pre\_processing\_top\_p)

Description: Top percentage of the probability distribution of next tokens, from which the model chooses the next token.

Type: `number`

Default: `0.9`

### <a name="input_orchestration_prompt_template"></a> [orchestration\_prompt\_template](#input\_orchestration\_prompt\_template)

Description: Prompt template for orchestration.

Type: `string`

Default: `"        You are orchestrating the flow of the agent. Based on the question and context, determine the next steps in the process:\n        Question: {question}\n        Context: {context}\n        Plan the next steps to follow the best strategy.\n"`

### <a name="input_orchestration_parser_mode"></a> [orchestration\_parser\_mode](#input\_orchestration\_parser\_mode)

Description: Parser mode for orchestration.

Type: `string`

Default: `"DEFAULT"`

### <a name="input_orchestration_prompt_creation_mode"></a> [orchestration\_prompt\_creation\_mode](#input\_orchestration\_prompt\_creation\_mode)

Description: Prompt creation mode for orchestration.

Type: `string`

Default: `"OVERRIDDEN"`

### <a name="input_orchestration_prompt_state"></a> [orchestration\_prompt\_state](#input\_orchestration\_prompt\_state)

Description: Prompt state for orchestration.

Type: `string`

Default: `"ENABLED"`

### <a name="input_orchestration_max_length"></a> [orchestration\_max\_length](#input\_orchestration\_max\_length)

Description: Maximum number of tokens to allow in the generated response.

Type: `number`

Default: `512`

### <a name="input_orchestration_stop_sequences"></a> [orchestration\_stop\_sequences](#input\_orchestration\_stop\_sequences)

Description: List of stop sequences that will stop generation.

Type: `list(string)`

Default:

```json
[
  "END"
]
```

### <a name="input_orchestration_temperature"></a> [orchestration\_temperature](#input\_orchestration\_temperature)

Description: Likelihood of the model selecting higher-probability options while generating a response.

Type: `number`

Default: `0.7`

### <a name="input_orchestration_top_k"></a> [orchestration\_top\_k](#input\_orchestration\_top\_k)

Description: Number of top most-likely candidates from which the model chooses the next token.

Type: `number`

Default: `50`

### <a name="input_orchestration_top_p"></a> [orchestration\_top\_p](#input\_orchestration\_top\_p)

Description: Top percentage of the probability distribution of next tokens, from which the model chooses the next token.

Type: `number`

Default: `0.9`

### <a name="input_post_processing_prompt_template"></a> [post\_processing\_prompt\_template](#input\_post\_processing\_prompt\_template)

Description: Prompt template for post-processing.

Type: `string`

Default: `"You are performing post-processing. Review the agent's output and refine the response for clarity and relevance:\nResponse: {response}\nContext: {context}\nEnsure the output is polished and aligns with the context.\n"`

### <a name="input_post_processing_parser_mode"></a> [post\_processing\_parser\_mode](#input\_post\_processing\_parser\_mode)

Description: Parser mode for post-processing.

Type: `string`

Default: `"DEFAULT"`

### <a name="input_post_processing_prompt_creation_mode"></a> [post\_processing\_prompt\_creation\_mode](#input\_post\_processing\_prompt\_creation\_mode)

Description: Prompt creation mode for post-processing.

Type: `string`

Default: `"OVERRIDDEN"`

### <a name="input_post_processing_prompt_state"></a> [post\_processing\_prompt\_state](#input\_post\_processing\_prompt\_state)

Description: Prompt state for post-processing.

Type: `string`

Default: `"DISABLED"`

### <a name="input_post_processing_max_length"></a> [post\_processing\_max\_length](#input\_post\_processing\_max\_length)

Description: Maximum number of tokens to allow in the generated response.

Type: `number`

Default: `512`

### <a name="input_post_processing_stop_sequences"></a> [post\_processing\_stop\_sequences](#input\_post\_processing\_stop\_sequences)

Description: List of stop sequences that will stop generation.

Type: `list(string)`

Default:

```json
[
  "END"
]
```

### <a name="input_post_processing_temperature"></a> [post\_processing\_temperature](#input\_post\_processing\_temperature)

Description: Likelihood of the model selecting higher-probability options while generating a response.

Type: `number`

Default: `0.7`

### <a name="input_post_processing_top_k"></a> [post\_processing\_top\_k](#input\_post\_processing\_top\_k)

Description: Number of top most-likely candidates from which the model chooses the next token.

Type: `number`

Default: `50`

### <a name="input_post_processing_top_p"></a> [post\_processing\_top\_p](#input\_post\_processing\_top\_p)

Description: Top percentage of the probability distribution of next tokens, from which the model chooses the next token.

Type: `number`

Default: `0.9`

### <a name="input_guardrail_id"></a> [guardrail\_id](#input\_guardrail\_id)

Description: Optional ID of an existing Guardrail to use.

Type: `string`

Default: `null`

### <a name="input_guardrail_version"></a> [guardrail\_version](#input\_guardrail\_version)

Description: Optional version of the existing Guardrail to use.

Type: `string`

Default: `null`

### <a name="input_guardrail_config"></a> [guardrail\_config](#input\_guardrail\_config)

Description: Optional full Guardrail configuration. If set, the module creates a Guardrail and version.

Type:

```hcl
object({
    description               = optional(string)
    blocked_input_messaging   = optional(string)
    blocked_outputs_messaging = optional(string)

    content_policy_config = optional(object({
      filters_config = list(object({
        type            = string
        input_strength  = string
        output_strength = string
      }))
    }))

    sensitive_information_policy_config = optional(object({
      pii_entities_config = optional(list(object({
        type   = string
        action = string
      })))
      regexes_config = optional(list(object({
        name        = string
        description = string
        pattern     = string
        action      = string
      })))
    }))

    topic_policy_config = optional(object({
      topics_config = list(object({
        name       = string
        examples   = list(string)
        type       = string
        definition = string
      }))
    }))

    word_policy_config = optional(object({
      managed_word_lists_config = optional(list(object({
        type = string
      })))
      words_config = optional(list(object({
        text = string
      })))
    }))
  })
```

Default: `null`

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
| <a name="output_guardrail_id"></a> [guardrail\_id](#output\_guardrail\_id) | ID of the created Guardrail |
| <a name="output_guardrail_version"></a> [guardrail\_version](#output\_guardrail\_version) | Version of the created Guardrail |
| <a name="output_knowledge_base"></a> [knowledge\_base](#output\_knowledge\_base) | Information about created Bedrock Knowledgebase |
| <a name="output_oss_collection"></a> [oss\_collection](#output\_oss\_collection) | Information about created OpenSearch Serverless collection |

<!-- TFDOCS_OUTPUTS_END -->

## License

**[MIT License](LICENSE)**

Copyright (c) 2024 **[Flaconi GmbH](https://github.com/flaconi)**
