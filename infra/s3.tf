resource "aws_s3_bucket" "contabilidade_s3_bucket" {
  bucket        = var.AWS_S3_BUCKET_NAME
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "contabilidade_acesso_s3_bucket" {
  bucket = aws_s3_bucket.contabilidade_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}