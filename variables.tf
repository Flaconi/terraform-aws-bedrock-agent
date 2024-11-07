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
