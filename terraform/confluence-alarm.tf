# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "aws_cloudwatch_fargate_vcpu_alarm" {
  alarm_name          = "${var.prefix}-fargate-vcpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  threshold           = "85"
  alarm_description   = "Alarm for when Fargate vCPU usage passes the 85% threshold for all available vCPUs in the account."
  alarm_actions       = [aws_sns_topic.aws_sns_topic_cloudwatch_alarms.arn]
  metric_query {
    id          = "e1"
    expression  = "m1/SERVICE_QUOTA(m1)*100"
    label       = "Percentage"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      metric_name = "ResourceCount"
      namespace   = "AWS/Usage"
      period      = "180"
      stat        = "Average"
      dimensions = {
        Type     = "Resource"
        Service  = "Fargate"
        Resource = "vCPU"
        Class    = "Standard/OnDemand"
      }
    }
  }
}

resource "aws_sns_topic_subscription" "aws_sns_topic_cw_alarm_subscription" {
  endpoint  = var.sns_email_alarms
  protocol  = "email"
  topic_arn = aws_sns_topic.aws_sns_topic_cloudwatch_alarms.arn
}

# SNS Topic for CloudWatch alarms
resource "aws_sns_topic" "aws_sns_topic_cloudwatch_alarms" {
  name         = "${var.prefix}-cloudwatch-alarms"
  display_name = "${var.prefix}-cloudwatch-alarms"
}

resource "aws_sns_topic_policy" "aws_sns_topic_cloudwatch_alarms_policy" {
  arn = aws_sns_topic.aws_sns_topic_cloudwatch_alarms.arn
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "AllowPublishAlarms",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : "sns:Publish",
        "Resource" : "${aws_sns_topic.aws_sns_topic_cloudwatch_alarms.arn}",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:${var.aws_region}:${local.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}