locals {
  # TODO: deprecate knowledgebase_model_id variable
  knowledgebase_embedding_model_id = var.knowledgebase_model_id != null ? var.knowledgebase_model_id : var.knowledgebase_embedding_model_id
  knowledgebase_access_model_ids = toset(distinct(concat(
    [local.knowledgebase_embedding_model_id],
    var.knowledgebase_access_model_ids
  )))
}
