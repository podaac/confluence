# logs
resource "aws_efs_file_system" "efs_fs_logs" {
  creation_token   = "${var.prefix}-logs"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-logs" }
}

resource "aws_efs_mount_target" "efs_mt_a_logs" {
  file_system_id = aws_efs_file_system.efs_fs_logs.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_logs" {
  file_system_id = aws_efs_file_system.efs_fs_logs.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_logs" {
  file_system_id = aws_efs_file_system.efs_fs_logs.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_logs" {
  file_system_id = aws_efs_file_system.efs_fs_logs.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# validation
resource "aws_efs_file_system" "efs_fs_val" {
  creation_token   = "${var.prefix}-validation"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-validation" }
}

resource "aws_efs_mount_target" "efs_mt_a_val" {
  file_system_id = aws_efs_file_system.efs_fs_val.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_val" {
  file_system_id = aws_efs_file_system.efs_fs_val.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_val" {
  file_system_id = aws_efs_file_system.efs_fs_val.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_val" {
  file_system_id = aws_efs_file_system.efs_fs_val.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# offline
resource "aws_efs_file_system" "efs_fs_off" {
  creation_token   = "${var.prefix}-offline"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-offline" }
}

resource "aws_efs_mount_target" "efs_mt_a_off" {
  file_system_id = aws_efs_file_system.efs_fs_off.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_off" {
  file_system_id = aws_efs_file_system.efs_fs_off.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_off" {
  file_system_id = aws_efs_file_system.efs_fs_off.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_off" {
  file_system_id = aws_efs_file_system.efs_fs_off.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# output
resource "aws_efs_file_system" "efs_fs_out" {
  creation_token   = "${var.prefix}-output"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-output" }
}

resource "aws_efs_mount_target" "efs_mt_a_out" {
  file_system_id = aws_efs_file_system.efs_fs_out.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_out" {
  file_system_id = aws_efs_file_system.efs_fs_out.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_out" {
  file_system_id = aws_efs_file_system.efs_fs_out.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_out" {
  file_system_id = aws_efs_file_system.efs_fs_out.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# diagnostics
resource "aws_efs_file_system" "efs_fs_diag" {
  creation_token   = "${var.prefix}-diagnostics"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-diagnostics" }
}

resource "aws_efs_mount_target" "efs_mt_a_diag" {
  file_system_id = aws_efs_file_system.efs_fs_diag.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_diag" {
  file_system_id = aws_efs_file_system.efs_fs_diag.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_diag" {
  file_system_id = aws_efs_file_system.efs_fs_diag.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_diag" {
  file_system_id = aws_efs_file_system.efs_fs_diag.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# moi
resource "aws_efs_file_system" "efs_fs_moi" {
  creation_token   = "${var.prefix}-moi"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-moi" }
}

resource "aws_efs_mount_target" "efs_mt_a_moi" {
  file_system_id = aws_efs_file_system.efs_fs_moi.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_moi" {
  file_system_id = aws_efs_file_system.efs_fs_moi.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_moi" {
  file_system_id = aws_efs_file_system.efs_fs_moi.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_moi" {
  file_system_id = aws_efs_file_system.efs_fs_moi.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# input
resource "aws_efs_file_system" "efs_fs_in" {
  creation_token   = "${var.prefix}-input"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-input" }
}

resource "aws_efs_mount_target" "efs_mt_a_in" {
  file_system_id = aws_efs_file_system.efs_fs_in.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_in" {
  file_system_id = aws_efs_file_system.efs_fs_in.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_in" {
  file_system_id = aws_efs_file_system.efs_fs_in.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_in" {
  file_system_id = aws_efs_file_system.efs_fs_in.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

# iterate access point
resource "aws_efs_access_point" "generate_efs_ap_in" {
  file_system_id = aws_efs_file_system.efs_fs_in.id
  tags           = { Name = "${var.prefix}-iterate" }
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
    path = "/"
  }
}

# flpe
resource "aws_efs_file_system" "efs_fs_flpe" {
  creation_token   = "${var.prefix}-flpe"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  tags             = { Name = "${var.prefix}-flpe" }
}

resource "aws_efs_mount_target" "efs_mt_a_flpe" {
  file_system_id = aws_efs_file_system.efs_fs_flpe.id
  subnet_id      = aws_subnet.subnet_a_public.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_b_flpe" {
  file_system_id = aws_efs_file_system.efs_fs_flpe.id
  subnet_id      = aws_subnet.subnet_b.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_c_flpe" {
  file_system_id = aws_efs_file_system.efs_fs_flpe.id
  subnet_id      = aws_subnet.subnet_c.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}

resource "aws_efs_mount_target" "efs_mt_d_flpe" {
  file_system_id = aws_efs_file_system.efs_fs_flpe.id
  subnet_id      = aws_subnet.subnet_d.id
  security_groups = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.efs_sg.id
  ]
}