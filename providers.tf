provider "opensearch" {
  url         = aws_opensearchserverless_collection.this.collection_endpoint
  healthcheck = false

  # We assume, that aws provider is configured with `assume_role` block.
  aws_assume_role_arn = data.aws_iam_session_context.this.issuer_arn
}
