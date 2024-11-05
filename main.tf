resource "aws_iam_role" "agent" {
  assume_role_policy = data.aws_iam_policy_document.agent_trust.json
  name_prefix        = "BedrockExecutionRoleForAgents_"
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "agent" {
  policy = data.aws_iam_policy_document.agent_permissions.json
  role   = aws_iam_role.agent.id
}

resource "aws_iam_role" "knowledgebase" {
  assume_role_policy = data.aws_iam_policy_document.knowledgebase_trust.json
  name_prefix        = "BedrockExecutionRoleForKnowledgeBase_"
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "knowledgebase" {
  policy = data.aws_iam_policy_document.knowledgebase_permissions.json
  role   = aws_iam_role.knowledgebase.id
}

# – OpenSearch Serverless Default –
# Create a Collection
resource "aws_opensearchserverless_collection" "this" {
  name        = var.oss_collection_name
  type        = "VECTORSEARCH"
  description = "Default collection created by Amazon Bedrock Knowledge base."
  depends_on = [
    aws_opensearchserverless_security_policy.security_policy,
    aws_opensearchserverless_security_policy.nw_policy
  ]
}

# Encryption Security Policy
resource "aws_opensearchserverless_security_policy" "security_policy" {
  name = "oss-security-policy-${var.oss_collection_name}"
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
  name = "nw-policy-${var.oss_collection_name}"
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
  name = "oss-access-policy-${var.oss_collection_name}"
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
        data.aws_caller_identity.current.arn
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
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
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

  depends_on = [time_sleep.wait_after_index_creation]
}

resource "aws_bedrockagent_data_source" "this" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = var.knowledgebase_name
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.s3_arn
    }
  }
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
}

resource "aws_bedrockagent_agent_alias" "this" {
  agent_alias_name = var.alias_name
  agent_id         = aws_bedrockagent_agent.this.agent_id
  description      = var.alias_description
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
