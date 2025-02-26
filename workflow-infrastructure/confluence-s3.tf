# SOS S3 Bucket
resource "aws_s3_bucket" "aws_s3_bucket_sos" {
  bucket        = "${var.prefix}-sos"
  force_destroy = true
  tags          = { Name = "${var.prefix}-sos" }
}

resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_sos_public_block" {
  bucket                  = aws_s3_bucket.aws_s3_bucket_sos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_sos_ownership" {
  bucket = aws_s3_bucket.aws_s3_bucket_sos.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_sos_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket_sos.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = true
  }
}

# JSON S3 Bucket
resource "aws_s3_bucket" "aws_s3_bucket_json" {
  bucket        = "${var.prefix}-json"
  force_destroy = true
  tags          = { Name = "${var.prefix}-json" }
}

resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_json_public_block" {
  bucket                  = aws_s3_bucket.aws_s3_bucket_json.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_json_ownership" {
  bucket = aws_s3_bucket.aws_s3_bucket_json.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_json_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket_json.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Config S3 Bucket
resource "aws_s3_bucket" "aws_s3_bucket_config" {
  bucket        = "${var.prefix}-config"
  force_destroy = true
  tags          = { Name = "${var.prefix}-config" }
}

resource "aws_s3_bucket_public_access_block" "aws_s3_bucket_config_public_block" {
  bucket                  = aws_s3_bucket.aws_s3_bucket_config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_bucket_config_ownership" {
  bucket = aws_s3_bucket.aws_s3_bucket_config.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_config_encryption" {
  bucket = aws_s3_bucket.aws_s3_bucket_config.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = true
  }
}
