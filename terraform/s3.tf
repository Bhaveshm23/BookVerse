resource "aws_s3_bucket" "tf_bookverse_covers_s3" {
  bucket = "bookverse-cover-images"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "bookverse_covers_block" {
  bucket                  = aws_s3_bucket.tf_bookverse_covers_s3.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bookverse_covers_policy" {
  bucket = aws_s3_bucket.tf_bookverse_covers_s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.tf_bookverse_covers_s3.arn}/*"
      }
    ]
  })
}