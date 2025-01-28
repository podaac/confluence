# AWS Batch service role and policy
resource "aws_iam_role" "aws_batch_service_role" {
  name = "${var.prefix}-batch-service-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "batch.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role_policy_attach" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = aws_iam_policy.batch_service_policy.arn
}

resource "aws_iam_policy" "batch_service_policy" {
  name        = "${var.prefix}-batch-service-policy"
  description = "Provides access for the AWS Batch service to manage the required resources, including Amazon EC2 and Amazon ECS resources"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeImages",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeVpcClassicLink",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:TerminateInstances",
          "ec2:RunInstances",
          "autoscaling:DescribeAccountLimits",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:CreateLaunchConfiguration",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:DeleteLaunchConfiguration",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:CreateOrUpdateTags",
          "autoscaling:SuspendProcesses",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ecs:DeleteCluster",
          "ecs:DescribeClusters",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListAccountSettings",
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:UpdateContainerAgent",
          "ecs:DeregisterContainerInstance",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "iam:GetInstanceProfile",
          "iam:GetRole"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "ecs:TagResource",
        "Resource" : [
          "arn:aws:ecs:*:*:task/*_Batch_*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : [
              "autoscaling.amazonaws.com",
              "ecs.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "RunInstances"
          }
        }
      }
    ]
  })

}

# Amazon ECS role and policy
resource "aws_iam_role" "ecs_exe_task_role" {
  name        = "${var.prefix}-ecs-exe-task-role"
  description = "Amazon ECS task execution role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ecs_exe_role_policy_attach" {
  role       = aws_iam_role.ecs_exe_task_role.name
  policy_arn = aws_iam_policy.ecs_exe_task_policy.arn
}

resource "aws_iam_policy" "ecs_exe_task_policy" {
  name        = "${var.prefix}-ecs-exe-task-policy"
  description = "Amazon ECS task execution policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })

}

# AWS Batch job role and policies
resource "aws_iam_role" "batch_job_role" {
  name        = "${var.prefix}-batch-job-role"
  description = "Amazon Batch job role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

# # S3
resource "aws_iam_role_policy_attachment" "batch_job_s3_role_policy" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = aws_iam_policy.batch_job_s3_policy.arn
}

resource "aws_iam_policy" "batch_job_s3_policy" {
  name        = "${var.prefix}-batch-job-s3-policy"
  description = "Amazon Batch job policy for S3 actions"
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
          "s3:ListBucketVersions"
        ],
        "Resource" : [
          "${aws_s3_bucket.aws_s3_bucket_sos.arn}",
          "${aws_s3_bucket.aws_s3_bucket_json.arn}",
          "${aws_s3_bucket.aws_s3_bucket_config.arn}",
          "${aws_s3_bucket.aws_s3_bucket_map.arn}"
        ]
      },
      {
        "Sid" : "AllGetPutObjects",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectAttributes",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "${aws_s3_bucket.aws_s3_bucket_sos.arn}/*",
          "${aws_s3_bucket.aws_s3_bucket_json.arn}/*",
          "${aws_s3_bucket.aws_s3_bucket_config.arn}/*",
          "${aws_s3_bucket.aws_s3_bucket_map.arn}/*"
        ]
      },
      {
        "Sid" : "AllDeleteObjects",
        "Effect" : "Allow",
        "Action" : [
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.aws_s3_bucket_map.arn}/*"
        ]
      }
    ]
  })
}


# # Step Functions
resource "aws_iam_role_policy_attachment" "batch_job_sfn_role_policy" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = aws_iam_policy.batch_job_sfn_policy.arn
}

resource "aws_iam_policy" "batch_job_sfn_policy" {
  name        = "${var.prefix}-batch-job-sfn-policy"
  description = "Amazon Batch job policy for Step Function actions"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowStartExecution",
        "Effect" : "Allow",
        "Action" : "states:StartExecution",
        "Resource" : "arn:aws:states:${var.aws_region}:${local.account_id}:stateMachine:${var.prefix}-workflow"
      },
      {
        "Sid" : "DescribeMapRun",
        "Effect" : "Allow",
        "Action" : "states:DescribeMapRun",
        "Resource" : "arn:aws:states:${var.aws_region}:${local.account_id}:mapRun:${var.prefix}-workflow/*"
      }
    ]
  })
}

# # SSM Parameters
resource "aws_iam_role_policy_attachment" "batch_job_ssm_role_policy" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = aws_iam_policy.batch_job_ssm_policy.arn
}

resource "aws_iam_policy" "batch_job_ssm_policy" {
  name        = "${var.prefix}-batch-job-ssm-policy"
  description = "Amazon Batch job policy to access SSM parameters"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowDescribeParameters",
        "Effect" : "Allow",
        "Action" : "ssm:DescribeParameters",
        "Resource" : "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${var.prefix}-hydrocron-key"
      },
      {
        "Sid" : "AllowGetParameter",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        "Resource" : "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${var.prefix}-hydrocron-key"
      }
    ]
  })
}