module "agent" {
  source = "../../"

  name       = "my-example"
  alias_name = "my-alias-name"

  agent_instructions = "Imagine you are a manager in a grocery store. Be kind and polite, and answer the question in an eloquent way."

  knowledgebase_name        = "my-knowledgebase"
  knowledgebase_description = "Description for my knowledgebase"

  s3_arn = var.s3_arn

  oss_collection_name = var.oss_collection_name

  oss_additional_roles_arns = var.oss_additional_roles_arns
}
