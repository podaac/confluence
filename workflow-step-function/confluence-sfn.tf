# Confluence Step Function State Machine
resource "aws_sfn_state_machine" "confluence_state_machine" {
  name       = "${var.prefix}-workflow"
  role_arn   = aws_iam_role.step_function_role.arn
  definition = templatefile("confluence-sfn-workflow.asl.json", { aws_region = var.aws_region, account_id = local.account_id, prefix = var.prefix })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.generate_cw_log_group_sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
  tracing_configuration {
    enabled = true
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "generate_cw_log_group_sfn" {
  name              = "/aws/states/${var.prefix}-workflow/"
  retention_in_days = 0
}