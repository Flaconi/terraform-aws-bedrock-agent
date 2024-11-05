data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_bedrock_foundation_model" "agent" {
  model_id = var.agent_model_id
}

data "aws_bedrock_foundation_model" "knowledgebase" {
  model_id = var.knowledgebase_model_id
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
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "agent_permissions" {
  statement {
    actions = ["bedrock:InvokeModel"]
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
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "knowledgebase_permissions" {
  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      data.aws_bedrock_foundation_model.knowledgebase.model_arn,
    ]
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
      var.s3_arn
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:ResourceAccount"
    }
  }
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${var.s3_arn}/*"
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:ResourceAccount"
    }
  }
}
