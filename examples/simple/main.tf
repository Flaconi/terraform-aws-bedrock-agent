module "agent" {
  source = "../../"

  name       = "my-example"
  alias_name = "my-alias-name"

  agent_instructions = "Imagine you are manager in a grocery store. Be kind and polite and answer question in eloquent way."

  knowledgebase_name        = "my-knowledgebase"
  knowledgebase_description = "Description for my knowledgebase"

  s3_arn  = "arn:aws:s3:::some-data-s3-bucket"
  oss_arn = "arn:aws:aoss:eu-central-1:123456789101:collection/some-collection"
}
