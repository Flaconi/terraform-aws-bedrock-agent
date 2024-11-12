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
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1536,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        }
      }
    }
  EOF
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
      embedding_model_arn = data.aws_bedrock_foundation_model.knowledgebase.model_arn
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
  data_deletion_policy = var.knowledgebase_data_deletion_policy

  depends_on = [aws_iam_role_policy_attachment.knowledgebase]
}

resource "aws_bedrockagent_agent" "this" {
  agent_name                  = var.name
  agent_resource_role_arn     = aws_iam_role.agent.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.agent_model_id
  instruction                 = var.agent_instructions

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

  depends_on = [aws_bedrockagent_agent_knowledge_base_association.this]
}
