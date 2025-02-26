# setfinder
resource "aws_cloudwatch_log_group" "generate_cw_log_group_setfinder" {
  name              = "/aws/batch/job/${var.prefix}-setfinder/"
  retention_in_days = 0
}

# combine_data
resource "aws_cloudwatch_log_group" "generate_cw_log_group_combine_data" {
  name              = "/aws/batch/job/${var.prefix}-combine-data/"
  retention_in_days = 0
}

# input
resource "aws_cloudwatch_log_group" "generate_cw_log_group_input" {
  name              = "/aws/batch/job/${var.prefix}-input/"
  retention_in_days = 0
}

# prediagnostics
resource "aws_cloudwatch_log_group" "generate_cw_log_group_prediagnostics" {
  name              = "/aws/batch/job/${var.prefix}-prediagnostics/"
  retention_in_days = 0
}

# priors
resource "aws_cloudwatch_log_group" "generate_cw_log_group_priors" {
  name              = "/aws/batch/job/${var.prefix}-priors/"
  retention_in_days = 0
}

# flpe
resource "aws_cloudwatch_log_group" "generate_cw_log_group_hivdi" {
  name              = "/aws/batch/job/${var.prefix}-hivdi/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_metroman" {
  name              = "/aws/batch/job/${var.prefix}-metroman/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_metroman_consolidation" {
  name              = "/aws/batch/job/${var.prefix}-metroman-consolidation/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_momma" {
  name              = "/aws/batch/job/${var.prefix}-momma/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_neobam" {
  name              = "/aws/batch/job/${var.prefix}-neobam/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_sad" {
  name              = "/aws/batch/job/${var.prefix}-sad/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_sic4dvar" {
  name              = "/aws/batch/job/${var.prefix}-sic4dvar/"
  retention_in_days = 0
}

# postdiagnostics
resource "aws_cloudwatch_log_group" "generate_cw_log_group_postdiagnostics" {
  name              = "/aws/batch/job/${var.prefix}-postdiagnostics/"
  retention_in_days = 0
}

# moi
resource "aws_cloudwatch_log_group" "generate_cw_log_group_moi" {
  name              = "/aws/batch/job/${var.prefix}-moi/"
  retention_in_days = 0
}

# offline
resource "aws_cloudwatch_log_group" "generate_cw_log_group_offline" {
  name              = "/aws/batch/job/${var.prefix}-offline/"
  retention_in_days = 0
}

# validation
resource "aws_cloudwatch_log_group" "generate_cw_log_group_validation" {
  name              = "/aws/batch/job/${var.prefix}-validation/"
  retention_in_days = 0
}

# output
resource "aws_cloudwatch_log_group" "generate_cw_log_group_output" {
  name              = "/aws/batch/job/${var.prefix}-output/"
  retention_in_days = 0
}

# init workflow
resource "aws_cloudwatch_log_group" "generate_cw_log_group_init" {
  name              = "/aws/batch/job/${var.prefix}-init-workflow/"
  retention_in_days = 0
}

# report
resource "aws_cloudwatch_log_group" "generate_cw_log_group_report" {
  name              = "/aws/batch/job/${var.prefix}-report/"
  retention_in_days = 0
}

# clean up
resource "aws_cloudwatch_log_group" "generate_cw_log_group_clean_up" {
  name              = "/aws/batch/job/${var.prefix}-clean-up/"
  retention_in_days = 0
}