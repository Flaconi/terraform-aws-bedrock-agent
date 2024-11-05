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
      collection_arn    = var.oss_arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
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
  instruction = var.agent_instructions

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
