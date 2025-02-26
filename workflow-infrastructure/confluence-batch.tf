# Compute environments

# # data
resource "aws_batch_compute_environment" "ce_data" {
  compute_environment_name = "${var.prefix}-data"
  compute_resources {
    max_vcpus          = 10000
    security_group_ids = [aws_vpc.vpc.default_security_group_id]
    subnets = [
      aws_subnet.subnet_a_private.id,
      aws_subnet.subnet_b.id,
      aws_subnet.subnet_c.id,
      aws_subnet.subnet_d.id,
    ]
    type = "FARGATE"
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach]
}

# # diagnostics
resource "aws_batch_compute_environment" "ce_diagnostics" {
  compute_environment_name = "${var.prefix}-diagnostics"
  compute_resources {
    max_vcpus          = 10000
    security_group_ids = [aws_vpc.vpc.default_security_group_id]
    subnets = [
      aws_subnet.subnet_a_private.id,
      aws_subnet.subnet_b.id,
      aws_subnet.subnet_c.id,
      aws_subnet.subnet_d.id,
    ]
    type = "FARGATE"
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach]
}

# # flpe
resource "aws_batch_compute_environment" "ce_flpe" {
  compute_environment_name = "${var.prefix}-flpe"
  compute_resources {
    max_vcpus          = 10000
    security_group_ids = [aws_vpc.vpc.default_security_group_id]
    subnets = [
      aws_subnet.subnet_a_private.id,
      aws_subnet.subnet_b.id,
      aws_subnet.subnet_c.id,
      aws_subnet.subnet_d.id,
    ]
    type = "FARGATE"
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach]
}

# # discharge and metrics
resource "aws_batch_compute_environment" "ce_discharge_metrics" {
  compute_environment_name = "${var.prefix}-discharge-metrics"
  compute_resources {
    max_vcpus          = 10000
    security_group_ids = [aws_vpc.vpc.default_security_group_id]
    subnets = [
      aws_subnet.subnet_a_private.id,
      aws_subnet.subnet_b.id,
      aws_subnet.subnet_c.id,
      aws_subnet.subnet_d.id,
    ]
    type = "FARGATE"
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach]
}

# Job Queues

# # combine_data
resource "aws_batch_job_queue" "jq_combine_data" {
  name     = "${var.prefix}-combine-data"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # setfinder
resource "aws_batch_job_queue" "jq_setfinder" {
  name     = "${var.prefix}-setfinder"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # flpe
resource "aws_batch_job_queue" "jq_flpe" {
  name     = "${var.prefix}-flpe"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_flpe.arn
  }
}

# # input
resource "aws_batch_job_queue" "jq_input" {
  name     = "${var.prefix}-input"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # moi
resource "aws_batch_job_queue" "jq_moi" {
  name     = "${var.prefix}-moi"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_flpe.arn
  }
}

# # offline
resource "aws_batch_job_queue" "jq_offline" {
  name     = "${var.prefix}-offline"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_discharge_metrics.arn
  }
}

# # output
resource "aws_batch_job_queue" "jq_output" {
  name     = "${var.prefix}-output"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # postdiagnostics flpe
resource "aws_batch_job_queue" "jq_postdiagnostics_flpe" {
  name     = "${var.prefix}-postdiagnostics-flpe"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_diagnostics.arn
  }
}

# # postdiagnostics moi
resource "aws_batch_job_queue" "jq_postdiagnostics_moi" {
  name     = "${var.prefix}-postdiagnostics-moi"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_diagnostics.arn
  }
}

# # prediagnostics
resource "aws_batch_job_queue" "jq_prediagnostics" {
  name     = "${var.prefix}-prediagnostics"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_diagnostics.arn
  }
}

# # priors
resource "aws_batch_job_queue" "jq_prior" {
  name     = "${var.prefix}-priors"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # validation
resource "aws_batch_job_queue" "jq_validation" {
  name     = "${var.prefix}-validation"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_discharge_metrics.arn
  }
}

# # init-workflow
resource "aws_batch_job_queue" "jq_init_workflow" {
  name     = "${var.prefix}-init-workflow"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # report
resource "aws_batch_job_queue" "jq_report" {
  name     = "${var.prefix}-report"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}

# # clean-up
resource "aws_batch_job_queue" "jq_clean_up" {
  name     = "${var.prefix}-clean-up"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.ce_data.arn
  }
}