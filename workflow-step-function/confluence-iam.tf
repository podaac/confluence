# Step Function Role
resource "aws_iam_role" "step_function_role" {
  name = "${var.prefix}-step-function-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "states.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# # Cloudwatch
resource "aws_iam_role_policy_attachment" "sfn_role_policy_attach_1" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_cloudwatch.arn
}

resource "aws_iam_policy" "sfn_cloudwatch" {
  name        = "${var.prefix}-sfn-cloudwatch-policy"
  description = "Step Function policy for CloudWatch Log delivery"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups"
        ],
        "Resource" : aws_cloudwatch_log_group.generate_cw_log_group_sfn.arn
      }
    ]
  })
}

# # Xray
resource "aws_iam_role_policy_attachment" "sfn_role_policy_attach_2" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_xray.arn
}

resource "aws_iam_policy" "sfn_xray" {
  name        = "${var.prefix}-sfn-xray-policy"
  description = "Step Function policy for X-Ray"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# # EventBridge
resource "aws_iam_role_policy_attachment" "sfn_role_policy_attach_3" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_event_bridge.arn
}

resource "aws_iam_policy" "sfn_event_bridge" {
  name        = "${var.prefix}-sfn-event-bridge-policy"
  description = "Step Function policy for EventBridge rules"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# # Batch
resource "aws_iam_role_policy_attachment" "sfn_role_policy_attach_4" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_batch.arn
}

resource "aws_iam_policy" "sfn_batch" {
  name        = "${var.prefix}-sfn-batch-policy"
  description = "Step Function policy for Batch jobs"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "batch:SubmitJob",
          "batch:DescribeJobs",
          "batch:TerminateJob",
          "batch:TagResource"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# # S3
resource "aws_iam_role_policy_attachment" "sfn_role_policy_attach_6" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_s3.arn
}

resource "aws_iam_policy" "sfn_s3" {
  name        = "${var.prefix}-sfn-s3-policy"
  description = "Step Function policy for access to S3 Bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowListAllBuckets",
        "Effect" : "Allow",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowListBuckets",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [
          "${data.aws_s3_bucket.s3_json.arn}",
          "${data.aws_s3_bucket.s3_map.arn}"
        ]
      },
      {
        "Sid" : "AllGetObjects",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectAttributes"
        ],
        "Resource" : [
          "${data.aws_s3_bucket.s3_json.arn}/*",
          "${data.aws_s3_bucket.s3_map.arn}/*"
        ]
      },
      {
        "Sid" : "AllPutObjects",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"

        ],
        "Resource" : [
          "${data.aws_s3_bucket.s3_map.arn}/*"
        ]
      }
    ]
  })
}

# # States
resource "aws_iam_role_policy_attachment" "sfn_role_policy_attach_7" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.sfn_states.arn
}

resource "aws_iam_policy" "sfn_states" {
  name        = "${var.prefix}-sfn-states-policy"
  description = "Allow Step Function state machine to execute Step Function state machine"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "states:StartExecution"
        ],
        "Resource" : [
          "${aws_sfn_state_machine.confluence_state_machine.arn}"
        ]
      }
    ]
  })
}
