variable "name" {
  description = "Name for the agent."
  type        = string
}

variable "alias_name" {
  description = "Name for the agent alias."
  type        = string
}

variable "alias_description" {
  description = "Description for the agent alias."
  type        = string
  default     = null
}

variable "agent_model_id" {
  description = "Model identifier for agent."
  type        = string
  default     = "anthropic.claude-v2"
}

variable "agent_instructions" {
  description = "Model identifier for agent."
  type        = string
}

variable "knowledgebase_name" {
  description = "Name for the knowledgebase."
  type        = string
}

variable "knowledgebase_description" {
  description = "Description for the knowledgebase."
  type        = string
}

variable "knowledgebase_model_id" {
  description = "Model identifier for Knowledgebase."
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

variable "knowledgebase_data_deletion_policy" {
  description = "Data deletion policy for a data source. Valid values: `RETAIN`, `DELETE`"
  type        = string
  default     = "RETAIN"
}

variable "s3_configuration" {
  description = "ARN of S3 bucket with data"
  type = object({
    bucket_arn              = string
    bucket_owner_account_id = optional(string)
    inclusion_prefixes      = optional(set(string))
  })
  validation {
    condition     = var.s3_configuration.inclusion_prefixes == null ? true : length(var.s3_configuration.inclusion_prefixes) == 1
    error_message = "For now s3 data source support only one prefix."
  }
}

variable "vector_ingestion_configuration" {
  type = object({
    chunking_configuration = object({
      chunking_strategy = string
      fixed_size_chunking_configuration = optional(object({
        max_tokens        = number
        overlap_percentage = optional(number)
      }))
      hierarchical_chunking_configuration = optional(object({
        overlap_tokens = number
        level_1        = object({ max_tokens = number })
        level_2        = object({ max_tokens = number })
      }))
      semantic_chunking_configuration = optional(object({
        breakpoint_percentile_threshold = number
        buffer_size                    = number
        max_token                      = number
      }))
    })
    custom_transformation_configuration = optional(object({
      intermediate_storage    = string
      transformation_function = string
    }))
  })
  default = {
    chunking_configuration = {
      chunking_strategy                 = "FIXED_SIZE"
      fixed_size_chunking_configuration = {
        max_tokens        = 300
        overlap_percentage = 20
      }
      hierarchical_chunking_configuration = null
      semantic_chunking_configuration     = null
    }
  }
}

variable "oss_collection_name" {
  description = "Name of OpenSearch Serverless Collection."
  type        = string
}

variable "oss_additional_roles_arns" {
  description = "Additional ARNs of roles to access OpenSearch"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the customization job and custom model."
  type        = map(string)
  default     = {}
}
