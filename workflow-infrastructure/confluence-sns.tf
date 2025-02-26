# SNS Topic
resource "aws_sns_topic" "aws_sns_topic_confluence_reports" {
  name         = "confluence-reports"
  display_name = "confluence-reports"
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_confluence_reports" {
  arn = aws_sns_topic.aws_sns_topic_confluence_reports.arn
  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
      {
        "Sid": "__default_statement_ID",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "SNS:Publish",
          "SNS:RemovePermission",
          "SNS:SetTopicAttributes",
          "SNS:DeleteTopic",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:AddPermission",
          "SNS:Subscribe"
        ],
        "Resource": "arn:aws:sns:us-west-2:${local.account_id}:test",
        "Condition": {
          "StringEquals": {
            "AWS:SourceOwner": "${local.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "aws_sns_topic_subscription_confluence_reports" {
  endpoint  = var.sns_email_reports
  protocol  = "email"
  topic_arn = aws_sns_topic.aws_sns_topic_confluence_reports.arn
}