variable "s3_configuration" {
  description = "ARN of S3 bucket with data"
  type = object({
    bucket_arn              = string
    bucket_owner_account_id = optional(string)
    inclusion_prefixes      = optional(string)
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
