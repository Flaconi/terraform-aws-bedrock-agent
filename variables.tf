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

variable "knowledgebase_name" {
  description = "Name for the knowledgebase."
  type        = string
}

variable "knowledgebase_decription" {
  description = "Description for the knowledgebase."
  type        = string
  default     = null
}

variable "knowledgebase_model_id" {
  description = "Model identifier for Knowledgebase."
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

variable "s3_arn" {
  description = "ARN of S3 bucket with data"
  type        = string
}

variable "oss_arn" {
  description = "ARN of OpenSearch Serverless Collection."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the customization job and custom model."
  type        = map(string)
  default     = {}
}
