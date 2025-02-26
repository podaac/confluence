# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "${var.prefix}" }
}

# Subnets
resource "aws_subnet" "subnet_a_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_a_public_cidr
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.prefix}-subnet-a-public" }
}

resource "aws_subnet" "subnet_a_private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_a_private_cidr
  availability_zone = "us-west-2a"
  tags              = { Name = "${var.prefix}-subnet-a-private" }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_b_cidr
  availability_zone = "us-west-2b"
  tags              = { Name = "${var.prefix}-subnet-b" }
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_c_cidr
  availability_zone = "us-west-2c"
  tags              = { Name = "${var.prefix}-subnet-c" }
}

resource "aws_subnet" "subnet_d" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_d_cidr
  availability_zone = "us-west-2d"
  tags              = { Name = "${var.prefix}-subnet-d" }
}

# EIP
resource "aws_eip" "eip_nat" {
  domain = "vpc"
  tags   = { Name = "${var.prefix}-eip" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.prefix}-igw" }
}

resource "aws_route_table" "rt_igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.prefix}-rt-igw" }
}

resource "aws_route" "route_igw" {
  route_table_id         = aws_route_table.rt_igw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rt_igw_assoc" {
  subnet_id      = aws_subnet.subnet_a_public.id
  route_table_id = aws_route_table.rt_igw.id
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id     = aws_eip.eip_nat.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.subnet_a_public.id
  tags              = { Name = "${var.prefix}-nat" }
  depends_on        = [aws_internet_gateway.igw]
}

resource "aws_route_table" "rt_nat" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.prefix}-rt-nat" }
}

resource "aws_route" "route_nat" {
  route_table_id         = aws_route_table.rt_nat.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "rt_subnet_a" {
  subnet_id      = aws_subnet.subnet_a_private.id
  route_table_id = aws_route_table.rt_nat.id
}

resource "aws_route_table_association" "rt_subnet_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt_nat.id
}

resource "aws_route_table_association" "rt_subnet_c" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.rt_nat.id
}

resource "aws_route_table_association" "rt_subnet_d" {
  subnet_id      = aws_subnet.subnet_d.id
  route_table_id = aws_route_table.rt_nat.id
}

# S3 endpoint (SOS & AWS ECR)
resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.us-west-2.s3"
  tags            = { Name = "${var.prefix}-endpoint-s3" }
  auto_accept     = true
  route_table_ids = [aws_route_table.rt_nat.id]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "Policy1687360944299",
    "Statement" : [
      {
        "Sid" : "AllowPodaacProtectedBucket",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : "arn:aws:s3:::podaac-swot-ops-cumulus-protected"
      },
      {
        "Sid" : "AllowPodaacProtectedObjects",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : "arn:aws:s3:::podaac-swot-ops-cumulus-protected/*"
      },
      {
        "Sid" : "AllowECR",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::prod-us-west-2-starport-layer-bucket/*"
      },
      {
        "Sid" : "AllowSOS",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectAttributes",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [
          "${aws_s3_bucket.aws_s3_bucket_sos.arn}",
          "${aws_s3_bucket.aws_s3_bucket_sos.arn}/*",
          "${aws_s3_bucket.aws_s3_bucket_json.arn}",
          "${aws_s3_bucket.aws_s3_bucket_json.arn}/*",
          "${aws_s3_bucket.aws_s3_bucket_config.arn}",
          "${aws_s3_bucket.aws_s3_bucket_config.arn}/*"
        ]
      }
    ]
  })
}

# ECR Endpoints
resource "aws_vpc_endpoint" "vpc_endpoint_ecr_dkr" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-west-2.ecr.dkr"
  tags              = { Name = "${var.prefix}-endpoint-ecr-dkr" }
  auto_accept       = true
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "vpc_endpoint_ecr_api" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-west-2.ecr.api"
  tags              = { Name = "${var.prefix}-endpoint-ecr-api" }
  auto_accept       = true
  vpc_endpoint_type = "Interface"
}

# CloudWatch Log Endpoint
resource "aws_vpc_endpoint" "vpc_endpoint_cw" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-west-2.logs"
  tags              = { Name = "${var.prefix}-endpoint-cw" }
  auto_accept       = true
  vpc_endpoint_type = "Interface"
}