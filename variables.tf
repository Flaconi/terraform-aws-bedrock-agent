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

variable "agent_idle_session_ttl" {
  description = "Number of seconds for which Amazon Bedrock keeps information about a user's conversation with the agent. A user interaction remains active for the amount of time specified."
  type        = number
  default     = 500

  validation {
    condition     = var.agent_idle_session_ttl >= 60 && var.agent_idle_session_ttl <= 3600
    error_message = "The agent_idle_session_ttl must be between 60 and 3600 seconds."
  }
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
  description = "Model identifier for Knowledgebase. (Deprecated) Use `knowledgebase_embedding_model_id` instead."
  type        = string
  default     = null
}

variable "knowledgebase_embedding_model_id" {
  description = "Embedding Model identifier for Knowledgebase."
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

variable "knowledgebase_access_model_ids" {
  description = "Model identifiers for Knowledgebase to have access to. This permissions would be added in addition to embedded model."
  type        = list(string)
  default     = []
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
  default = {
    chunking_configuration = {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration = {
        max_tokens         = 300
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

# KNOWLEDGE_BASE_RESPONSE_GENERATION Configuration
variable "knowledge_base_response_generation_prompt_template" {
  description = "Prompt template for pre-processing."
  type        = string
  default     = <<EOF
        You are a helpful assistant. Answer the following question using the context provided:
        Question: {question}
        Context: {context}
        Your response should be thoughtful, detailed, and relevant to the provided context.
        EOF
}

variable "knowledge_base_response_generation_parser_mode" {
  description = "Parser mode for pre-processing."
  type        = string
  default     = "DEFAULT"
}

variable "knowledge_base_response_generation_prompt_creation_mode" {
  description = "Prompt creation mode for pre-processing."
  type        = string
  default     = "OVERRIDDEN"
}

variable "knowledge_base_response_generation_prompt_state" {
  description = "Prompt state for pre-processing."
  type        = string
  default     = "ENABLED"
}

variable "knowledge_base_response_generation_max_length" {
  description = "Maximum number of tokens to allow in the generated response."
  type        = number
  default     = 512
}

variable "knowledge_base_response_generation_stop_sequences" {
  description = "List of stop sequences that will stop generation."
  type        = list(string)
  default     = ["END"]
}

variable "knowledge_base_response_generation_temperature" {
  description = "Likelihood of the model selecting higher-probability options while generating a response."
  type        = number
  default     = 0.7
}

variable "knowledge_base_response_generation_top_k" {
  description = "Number of top most-likely candidates from which the model chooses the next token."
  type        = number
  default     = 50
}

variable "knowledge_base_response_generation_top_p" {
  description = "Top percentage of the probability distribution of next tokens, from which the model chooses the next token."
  type        = number
  default     = 0.9
}

# PRE_PROCESSING Configuration
variable "pre_processing_prompt_template" {
  description = "Prompt template for pre-processing."
  type        = string
  default     = <<EOF
        You are preparing the input. Extract relevant context and pre-process the following question:
        Question: {question}
        Context: {context}
        Pre-processing should focus on extracting the core information.
        EOF
}

variable "pre_processing_parser_mode" {
  description = "Parser mode for pre-processing."
  type        = string
  default     = "DEFAULT" # Change to OVERRIDDEN if necessary
}

variable "pre_processing_prompt_creation_mode" {
  description = "Prompt creation mode for pre-processing."
  type        = string
  default     = "OVERRIDDEN"
}

variable "pre_processing_prompt_state" {
  description = "Prompt state for pre-processing."
  type        = string
  default     = "ENABLED"
}

variable "pre_processing_max_length" {
  description = "Maximum number of tokens to allow in the generated response."
  type        = number
  default     = 512
}

variable "pre_processing_stop_sequences" {
  description = "List of stop sequences that will stop generation."
  type        = list(string)
  default     = ["END"]
}

variable "pre_processing_temperature" {
  description = "Likelihood of the model selecting higher-probability options while generating a response."
  type        = number
  default     = 0.7
}

variable "pre_processing_top_k" {
  description = "Number of top most-likely candidates from which the model chooses the next token."
  type        = number
  default     = 50
}

variable "pre_processing_top_p" {
  description = "Top percentage of the probability distribution of next tokens, from which the model chooses the next token."
  type        = number
  default     = 0.9
}

# ORCHESTRATION Configuration
variable "orchestration_prompt_template" {
  description = "Prompt template for orchestration."
  type        = string
  default     = <<EOF
        You are orchestrating the flow of the agent. Based on the question and context, determine the next steps in the process:
        Question: {question}
        Context: {context}
        Plan the next steps to follow the best strategy.
        EOF
}

variable "orchestration_parser_mode" {
  description = "Parser mode for orchestration."
  type        = string
  default     = "DEFAULT"
}

variable "orchestration_prompt_creation_mode" {
  description = "Prompt creation mode for orchestration."
  type        = string
  default     = "OVERRIDDEN"
}

variable "orchestration_prompt_state" {
  description = "Prompt state for orchestration."
  type        = string
  default     = "ENABLED"
}

variable "orchestration_max_length" {
  description = "Maximum number of tokens to allow in the generated response."
  type        = number
  default     = 512
}

variable "orchestration_stop_sequences" {
  description = "List of stop sequences that will stop generation."
  type        = list(string)
  default     = ["END"]
}

variable "orchestration_temperature" {
  description = "Likelihood of the model selecting higher-probability options while generating a response."
  type        = number
  default     = 0.7
}

variable "orchestration_top_k" {
  description = "Number of top most-likely candidates from which the model chooses the next token."
  type        = number
  default     = 50
}

variable "orchestration_top_p" {
  description = "Top percentage of the probability distribution of next tokens, from which the model chooses the next token."
  type        = number
  default     = 0.9
}

# POST_PROCESSING Configuration
variable "post_processing_prompt_template" {
  description = "Prompt template for post-processing."
  type        = string
  default     = <<EOF
You are performing post-processing. Review the agent's output and refine the response for clarity and relevance:
Response: {response}
Context: {context}
Ensure the output is polished and aligns with the context.
EOF
}

variable "post_processing_parser_mode" {
  description = "Parser mode for post-processing."
  type        = string
  default     = "DEFAULT"
}

variable "post_processing_prompt_creation_mode" {
  description = "Prompt creation mode for post-processing."
  type        = string
  default     = "OVERRIDDEN"
}

variable "post_processing_prompt_state" {
  description = "Prompt state for post-processing."
  type        = string
  default     = "DISABLED"
}

variable "post_processing_max_length" {
  description = "Maximum number of tokens to allow in the generated response."
  type        = number
  default     = 512
}

variable "post_processing_stop_sequences" {
  description = "List of stop sequences that will stop generation."
  type        = list(string)
  default     = ["END"]
}

variable "post_processing_temperature" {
  description = "Likelihood of the model selecting higher-probability options while generating a response."
  type        = number
  default     = 0.7
}

variable "post_processing_top_k" {
  description = "Number of top most-likely candidates from which the model chooses the next token."
  type        = number
  default     = 50
}

variable "post_processing_top_p" {
  description = "Top percentage of the probability distribution of next tokens, from which the model chooses the next token."
  type        = number
  default     = 0.9
}

# OpenSearch Index Configuration
#
# IMPORTANT: Ensure your mappings are compatible with the embedding model
# used by the Bedrock Knowledge Base or RAG application.

variable "opensearch_index_name" {
  description = "Name of the OpenSearch index"
  type        = string
  default     = "bedrock-knowledge-base-default-index"
}

variable "opensearch_number_of_shards" {
  description = "Number of primary shards for the OpenSearch index"
  type        = string
  default     = "2"
}

variable "opensearch_number_of_replicas" {
  description = "Number of replica shards for the OpenSearch index"
  type        = string
  default     = "0"
}

variable "opensearch_index_knn" {
  description = "Enable k-NN indexing for the OpenSearch index"
  type        = bool
  default     = true
}

variable "opensearch_index_knn_algo_param_ef_search" {
  description = "ef_search parameter used by the k-NN algorithm"
  type        = string
  default     = "512"
}
variable "opensearch_index_mappings" {
  description = "The structured OpenSearch index mapping"
  type = object({
    properties = map(object({
      type      = string
      dimension = optional(number)
      method = optional(object({
        name       = string
        engine     = string
        space_type = string
        parameters = optional(map(number))
      }))
    }))
  })
  default = {
    properties = {
      "bedrock-knowledge-base-default-vector" = {
        type      = "knn_vector"
        dimension = 1536
        method = {
          name       = "hnsw"
          engine     = "faiss"
          space_type = "l2"
          parameters = {
            m               = 16
            ef_construction = 512
          }
        }
      }
    }
  }
}

variable "guardrail_id" {
  description = "Optional ID of an existing Guardrail to use."
  type        = string
  default     = null
}

variable "guardrail_version" {
  description = "Optional version of the existing Guardrail to use."
  type        = string
  default     = null
}

variable "guardrail_config" {
  description = "Optional full Guardrail configuration. If set, the module creates a Guardrail and version."
  type = object({
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
  default = null
}
variable "additional_agent_policy_statements" {
  description = "Optional additional IAM policy statements for the Bedrock agent role"
  type = list(object({
    sid       = optional(string)
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = []
}

variable "additional_knowledgebase_policy_statements" {
  description = "Optional additional IAM policy statements for the Bedrock knowledge base role"
  type = list(object({
    sid       = optional(string)
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the customization job and custom model."
  type        = map(string)
  default     = {}
}
