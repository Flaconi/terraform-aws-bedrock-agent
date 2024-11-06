provider "opensearch" {
  url                 = aws_opensearchserverless_collection.this.collection_endpoint
  aws_assume_role_arn = data.aws_iam_session_context.this.issuer_arn
  healthcheck         = false
}
