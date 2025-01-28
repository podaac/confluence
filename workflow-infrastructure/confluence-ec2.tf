
# Amazon EC2 Launch Template
resource "aws_launch_template" "aws_ec2_lt_efs" {
  name = "${var.prefix}-efs"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp2"
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.aws_ec2_efs_profile.arn
  }
  key_name = data.aws_key_pair.ec2_key_pair.key_name
  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default_tags, { Name = "${var.prefix}-efs" })
  }
  vpc_security_group_ids = [aws_security_group.efs_sg.id, aws_security_group.ssh_sg.id]
  update_default_version = "true"
  user_data              = base64encode(templatefile("./scripts/ec2-efs-user-data.sh", { logs = aws_efs_file_system.efs_fs_logs.id, validation = aws_efs_file_system.efs_fs_val.id, offline = aws_efs_file_system.efs_fs_off.id, output = aws_efs_file_system.efs_fs_out.id, diagnostics = aws_efs_file_system.efs_fs_diag.id, moi = aws_efs_file_system.efs_fs_moi.id, input = aws_efs_file_system.efs_fs_in.id, flpe = aws_efs_file_system.efs_fs_flpe.id }))
}

# Amazon EC2 instance profile, role, and policy
resource "aws_iam_instance_profile" "aws_ec2_efs_profile" {
  name = "${var.prefix}-ec2-efs-role"
  role = aws_iam_role.aws_ec2_efs_role.name
}

resource "aws_iam_role" "aws_ec2_efs_role" {
  name = "${var.prefix}-ec2-efs-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : { "Service" : "ec2.amazonaws.com" },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}