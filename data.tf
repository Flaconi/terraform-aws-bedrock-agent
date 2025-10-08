data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

data "aws_iam_session_context" "this" {
  arn = data.aws_caller_identity.this.arn
}

data "aws_bedrock_foundation_model" "agent" {
  model_id = var.agent_model_id
}

data "aws_bedrock_foundation_model" "knowledgebase" {
  for_each = local.knowledgebase_access_model_ids

  model_id = each.value
}

data "aws_iam_policy_document" "agent_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.this.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:bedrock:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "agent_permissions" {
  statement {
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = [
      data.aws_bedrock_foundation_model.agent.model_arn,
    ]
  }
  statement {
    actions = ["bedrock:Retrieve"]
    resources = [
      aws_bedrockagent_knowledge_base.this.arn
    ]
  }
}

data "aws_iam_policy_document" "knowledgebase_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.this.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:bedrock:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:knowledge-base/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "knowledgebase_permissions" {
  statement {
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [for id in local.knowledgebase_access_model_ids :
      data.aws_bedrock_foundation_model.knowledgebase[id].model_arn
    ]
  }
  statement {
    sid     = "AllowRerank"
    actions = [
      "bedrock:Rerank"
    ]
    resources = ["*"]
  }
  statement {
    actions = ["aoss:APIAccessAll"]
    resources = [
      aws_opensearchserverless_collection.this.arn
    ]
  }
  statement {
    actions = ["s3:ListBucket"]
    resources = [
      var.s3_configuration.bucket_arn
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.this.account_id]
      variable = "aws:ResourceAccount"
    }
  }
  statement {
    actions = ["s3:GetObject"]
    resources = var.s3_configuration.inclusion_prefixes == null ? [
      "${var.s3_configuration.bucket_arn}/*"
      ] : [for prefix in var.s3_configuration.inclusion_prefixes :
      "${var.s3_configuration.bucket_arn}/${prefix}*"
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.this.account_id]
      variable = "aws:ResourceAccount"
    }
  }
}
