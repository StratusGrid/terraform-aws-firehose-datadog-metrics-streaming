#Firehose stores data that failed to upload to DataDog in this s3 bucket.
resource "aws_s3_bucket" "datadog_aws_bucket" {
  bucket = var.name
}

resource "aws_s3_bucket_acl" "failed_data_bucket_acl" {
  bucket = aws_s3_bucket.datadog_aws_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "failed_data_bucket_encryption" {
  bucket = aws_s3_bucket.datadog_aws_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "failed_data_bucket_public_access_block" {
  bucket = aws_s3_bucket.datadog_aws_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.datadog_aws_bucket.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"ForceSSLOnlyAccess",
      "Effect":"Deny",
      "Principal":"*",
      "Action":"s3:*",
      "Resource":"arn:aws:s3:::${aws_s3_bucket.datadog_aws_bucket.id}/*",
      "Condition":{
         "Bool":{
            "aws:SecureTransport": "false"
          }
       }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_lifecycle_configuration" "failed_data_bucket_config" {
  bucket = aws_s3_bucket.datadog_aws_bucket.bucket

  rule {
    id = "faileddata"

    expiration {
      days = 5
    }
    status = "Enabled"
  }
}
