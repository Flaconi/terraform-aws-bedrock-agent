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
  value       = aws_bedrockagent_agent_alias.this
}
