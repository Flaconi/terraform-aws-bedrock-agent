resource "aws_iam_role" "agent" {
  assume_role_policy = data.aws_iam_policy_document.agent_trust.json
  name_prefix        = "BedrockExecutionRoleForAgents_"
  path               = "/service-role/"

  tags = var.tags
}

resource "aws_iam_policy" "agent" {
  policy = data.aws_iam_policy_document.agent_permissions.json
  name   = aws_iam_role.agent.name
  path   = "/service-role/"

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "agent" {
  role       = aws_iam_role.agent.id
  policy_arn = aws_iam_policy.agent.arn
}

resource "aws_iam_role" "knowledgebase" {
  assume_role_policy = data.aws_iam_policy_document.knowledgebase_trust.json
  name_prefix        = "BedrockExecutionRoleForKnowledgeBase_"
  path               = "/service-role/"

  tags = var.tags
}

resource "aws_iam_policy" "knowledgebase" {
  policy = data.aws_iam_policy_document.knowledgebase_permissions.json
  name   = aws_iam_role.knowledgebase.name
  path   = "/service-role/"

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "knowledgebase" {
  role       = aws_iam_role.knowledgebase.id
  policy_arn = aws_iam_policy.knowledgebase.arn
}

resource "aws_opensearchserverless_collection" "this" {
  name        = var.oss_collection_name
  type        = "VECTORSEARCH"
  description = "Default collection created by Amazon Bedrock Knowledge base."
  depends_on = [
    aws_opensearchserverless_security_policy.security_policy,
    aws_opensearchserverless_security_policy.nw_policy
  ]

  tags = var.tags
}

# Encryption Security Policy
resource "aws_opensearchserverless_security_policy" "security_policy" {
  name = var.oss_collection_name
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${var.oss_collection_name}"]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# Network policy
resource "aws_opensearchserverless_security_policy" "nw_policy" {
  name = var.oss_collection_name
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/${var.oss_collection_name}"]
        },
      ]
      AllowFromPublic = true,
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.oss_collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}


# Data policy
resource "aws_opensearchserverless_access_policy" "data_policy" {
  name = var.oss_collection_name
  type = "data"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            "index/${aws_opensearchserverless_collection.this.name}/*"
          ]
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection"
          Resource = [
            "collection/${aws_opensearchserverless_collection.this.name}"
          ]
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = concat([
        aws_iam_role.knowledgebase.arn,
        ],
        var.oss_additional_roles_arns
      )
    }
  ])
}

# OpenSearch index
resource "time_sleep" "wait_before_index_creation" {
  depends_on      = [aws_opensearchserverless_access_policy.data_policy]
  create_duration = "60s" # Wait for 60 seconds before creating the index
}

resource "opensearch_index" "default_oss_index" {
  name                           = var.opensearch_index_name
  number_of_shards               = var.opensearch_number_of_shards
  number_of_replicas             = var.opensearch_number_of_replicas
  index_knn                      = var.opensearch_index_knn
  index_knn_algo_param_ef_search = var.opensearch_index_knn_algo_param_ef_search
  mappings                       = jsonencode(var.opensearch_index_mappings)
  force_destroy                  = true

  depends_on = [
    time_sleep.wait_before_index_creation,
    aws_opensearchserverless_access_policy.data_policy,
    aws_opensearchserverless_collection.this
  ]

  lifecycle {
    ignore_changes = [mappings]
  }
}

# OpenSearch index
resource "time_sleep" "wait_after_index_creation" {
  depends_on      = [opensearch_index.default_oss_index]
  create_duration = "60s" # Wait for 60 seconds after creating the index
}

resource "aws_bedrockagent_knowledge_base" "this" {
  name     = var.knowledgebase_name
  role_arn = aws_iam_role.knowledgebase.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.knowledgebase[var.knowledgebase_embedding_model_id].model_arn
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.this.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  tags = var.tags

  depends_on = [time_sleep.wait_after_index_creation]
}

resource "aws_bedrockagent_data_source" "this" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = var.knowledgebase_name
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn              = var.s3_configuration.bucket_arn
      bucket_owner_account_id = var.s3_configuration.bucket_owner_account_id
      inclusion_prefixes      = var.s3_configuration.inclusion_prefixes
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = var.vector_ingestion_configuration.chunking_configuration.chunking_strategy

      dynamic "fixed_size_chunking_configuration" {
        for_each = var.vector_ingestion_configuration.chunking_configuration.chunking_strategy == "FIXED_SIZE" ? [1] : []
        content {
          max_tokens         = var.vector_ingestion_configuration.chunking_configuration.fixed_size_chunking_configuration.max_tokens
          overlap_percentage = var.vector_ingestion_configuration.chunking_configuration.fixed_size_chunking_configuration.overlap_percentage
        }
      }

      dynamic "hierarchical_chunking_configuration" {
        for_each = var.vector_ingestion_configuration.chunking_configuration.chunking_strategy == "HIERARCHICAL" ? [1] : []
        content {
          overlap_tokens = var.vector_ingestion_configuration.chunking_configuration.hierarchical_chunking_configuration.overlap_tokens

          level_configuration {
            max_tokens = var.vector_ingestion_configuration.chunking_configuration.hierarchical_chunking_configuration.level_1.max_tokens
          }

          level_configuration {
            max_tokens = var.vector_ingestion_configuration.chunking_configuration.hierarchical_chunking_configuration.level_2.max_tokens
          }
        }
      }

      dynamic "semantic_chunking_configuration" {
        for_each = var.vector_ingestion_configuration.chunking_configuration.chunking_strategy == "SEMANTIC" ? [1] : []
        content {
          breakpoint_percentile_threshold = var.vector_ingestion_configuration.chunking_configuration.semantic_chunking_configuration.breakpoint_percentile_threshold
          buffer_size                     = var.vector_ingestion_configuration.chunking_configuration.semantic_chunking_configuration.buffer_size
          max_token                       = var.vector_ingestion_configuration.chunking_configuration.semantic_chunking_configuration.max_token
        }
      }
    }
  }

  data_deletion_policy = var.knowledgebase_data_deletion_policy

  depends_on = [aws_iam_role_policy_attachment.knowledgebase]
}

resource "aws_bedrockagent_agent" "this" {
  agent_name                  = var.name
  agent_resource_role_arn     = aws_iam_role.agent.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.agent_model_id
  instruction                 = var.agent_instructions

  prompt_override_configuration {
    prompt_configurations {
      # KNOWLEDGE_BASE_RESPONSE_GENERATION step
      base_prompt_template = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_prompt_template : null

      inference_configuration {
        max_length     = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_max_length : null
        stop_sequences = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_stop_sequences : null
        temperature    = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_temperature : null
        top_k          = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_top_k : null
        top_p          = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_top_p : null
      }
      parser_mode          = var.knowledge_base_response_generation_parser_mode
      prompt_creation_mode = var.knowledge_base_response_generation_prompt_creation_mode
      prompt_state         = var.knowledge_base_response_generation_prompt_creation_mode == "OVERRIDDEN" ? var.knowledge_base_response_generation_prompt_state : null
      prompt_type          = "KNOWLEDGE_BASE_RESPONSE_GENERATION"
    }
    # PRE_PROCESSING step
    prompt_configurations {
      base_prompt_template = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_prompt_template : null

      inference_configuration {
        max_length     = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_max_length : null
        stop_sequences = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_stop_sequences : null
        temperature    = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_temperature : null
        top_k          = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_top_k : null
        top_p          = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_top_p : null
      }
      parser_mode          = var.pre_processing_parser_mode
      prompt_creation_mode = var.pre_processing_prompt_creation_mode
      prompt_state         = var.pre_processing_prompt_creation_mode == "OVERRIDDEN" ? var.pre_processing_prompt_state : null
      prompt_type          = "PRE_PROCESSING"
    }
    # ORCHESTRATION step
    prompt_configurations {
      base_prompt_template = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_prompt_template : null

      inference_configuration {
        max_length     = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_max_length : null
        stop_sequences = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_stop_sequences : null
        temperature    = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_temperature : null
        top_k          = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_top_k : null
        top_p          = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_top_p : null
      }
      parser_mode          = var.orchestration_parser_mode
      prompt_creation_mode = var.orchestration_prompt_creation_mode
      prompt_state         = var.orchestration_prompt_creation_mode == "OVERRIDDEN" ? var.orchestration_prompt_state : null
      prompt_type          = "ORCHESTRATION"
    }
    # POST_PROCESSING step
    prompt_configurations {
      base_prompt_template = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_prompt_template : null

      inference_configuration {
        max_length     = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_max_length : null
        stop_sequences = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_stop_sequences : null
        temperature    = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_temperature : null
        top_k          = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_top_k : null
        top_p          = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_top_p : null
      }

      parser_mode          = var.post_processing_parser_mode
      prompt_creation_mode = var.post_processing_prompt_creation_mode
      prompt_state         = var.post_processing_prompt_creation_mode == "OVERRIDDEN" ? var.post_processing_prompt_state : null
      prompt_type          = "POST_PROCESSING"
    }
  }

  dynamic "guardrail_configuration" {
    for_each = var.guardrail_config != null ? [1] : (var.guardrail_id != null ? [1] : [])
    content {
      guardrail_identifier = var.guardrail_config != null ? aws_bedrock_guardrail.this[0].guardrail_id : var.guardrail_id
      guardrail_version    = var.guardrail_config != null ? aws_bedrock_guardrail_version.this[0].version : var.guardrail_version
    }
  }

  depends_on = [
    aws_bedrockagent_knowledge_base.this
  ]

  tags = var.tags
}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [aws_bedrockagent_agent.this]

  create_duration = "10s"
}

resource "aws_bedrockagent_agent_knowledge_base_association" "this" {
  agent_id             = aws_bedrockagent_agent.this.id
  description          = var.knowledgebase_description
  knowledge_base_id    = aws_bedrockagent_knowledge_base.this.id
  knowledge_base_state = "ENABLED"

  depends_on = [time_sleep.wait_10_seconds]
}

resource "aws_bedrockagent_agent_alias" "this" {
  agent_alias_name = var.alias_name
  agent_id         = aws_bedrockagent_agent.this.agent_id
  description      = var.alias_description

  routing_configuration {
    agent_version = aws_bedrockagent_agent.this.agent_version
  }

  lifecycle {
    ignore_changes = [routing_configuration]
  }

  depends_on = [aws_bedrockagent_agent_knowledge_base_association.this]
}

resource "aws_bedrock_guardrail" "this" {
  count = var.guardrail_config != null ? 1 : 0

  name                      = "${var.name}-guardrail"
  description               = coalesce(var.guardrail_config.description, "Guardrail for ${var.name}")
  blocked_input_messaging   = coalesce(var.guardrail_config.blocked_input_messaging, "Input blocked")
  blocked_outputs_messaging = coalesce(var.guardrail_config.blocked_outputs_messaging, "Output blocked")

  dynamic "content_policy_config" {
    for_each = var.guardrail_config.content_policy_config != null ? [1] : []
    content {
      dynamic "filters_config" {
        for_each = var.guardrail_config.content_policy_config.filters_config
        content {
          type            = filters_config.value.type
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
        }
      }
    }
  }

  dynamic "sensitive_information_policy_config" {
    for_each = var.guardrail_config.sensitive_information_policy_config != null ? [1] : []
    content {
      dynamic "pii_entities_config" {
        for_each = var.guardrail_config.sensitive_information_policy_config.pii_entities_config != null ? var.guardrail_config.sensitive_information_policy_config.pii_entities_config : []
        content {
          type   = pii_entities_config.value.type
          action = pii_entities_config.value.action
        }
      }
      dynamic "regexes_config" {
        for_each = var.guardrail_config.sensitive_information_policy_config.regexes_config != null ? var.guardrail_config.sensitive_information_policy_config.regexes_config : []
        content {
          name        = regexes_config.value.name
          description = regexes_config.value.description
          pattern     = regexes_config.value.pattern
          action      = regexes_config.value.action
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = var.guardrail_config.topic_policy_config != null ? [1] : []
    content {
      dynamic "topics_config" {
        for_each = var.guardrail_config.topic_policy_config.topics_config
        content {
          name       = topics_config.value.name
          examples   = topics_config.value.examples
          type       = topics_config.value.type
          definition = topics_config.value.definition
        }
      }
    }
  }

  dynamic "word_policy_config" {
    for_each = var.guardrail_config.word_policy_config != null ? [1] : []
    content {
      dynamic "managed_word_lists_config" {
        for_each = var.guardrail_config.word_policy_config.managed_word_lists_config != null ? var.guardrail_config.word_policy_config.managed_word_lists_config : []
        content {
          type = managed_word_lists_config.value.type
        }
      }
      dynamic "words_config" {
        for_each = var.guardrail_config.word_policy_config.words_config != null ? var.guardrail_config.word_policy_config.words_config : []
        content {
          text = words_config.value.text
        }
      }
    }
  }
}

resource "aws_bedrock_guardrail_version" "this" {
  count         = var.guardrail_config != null ? 1 : 0
  guardrail_arn = aws_bedrock_guardrail.this[0].guardrail_arn
  description   = "Version for ${var.name}-guardrail"
}
