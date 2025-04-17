output "oss_collection" {
  description = "Information about created OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this
}

output "knowledge_base" {
  description = "Information about created Bedrock Knowledgebase"
  value       = aws_bedrockagent_knowledge_base.this
}

output "agent" {
  description = "Information about created Bedrock Agent"
  value       = aws_bedrockagent_agent.this
}

output "agent_alias" {
  description = "Information about created Bedrock Agent Alias"
  value = {
    id               = aws_bedrockagent_agent_alias.this.id
    agent_id         = aws_bedrockagent_agent_alias.this.agent_id
    description      = aws_bedrockagent_agent_alias.this.description
    agent_alias_arn  = aws_bedrockagent_agent_alias.this.agent_alias_arn
    agent_alias_id   = aws_bedrockagent_agent_alias.this.agent_alias_id
    agent_alias_name = aws_bedrockagent_agent_alias.this.agent_alias_name
  }
}
