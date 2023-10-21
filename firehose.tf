resource "aws_iam_role" "firehose_datadog_role" {
  name = "${var.name}-firehose"
  tags = local.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "datadog_firehose_stream" {
  name        = var.name
  destination = "http_endpoint"

  http_endpoint_configuration {
    url                = var.datadog_firehose_delivery_stream_url
    name               = "Datadog"
    access_key         = var.datadog_api_key
    buffering_size     = 4
    buffering_interval = 60
    role_arn           = aws_iam_role.firehose_datadog_role.arn
    s3_backup_mode     = "FailedDataOnly"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_datadog_role.arn
      bucket_arn         = aws_s3_bucket.datadog_aws_bucket.arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
    }

    request_configuration {
      content_encoding = "GZIP"
    }
  }
}

resource "aws_iam_role_policy" "metric_stream_s3_failed_upload_backup" {
  name = "${var.name}-s3-failed-upload-backup"
  role = aws_iam_role.firehose_datadog_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
               "s3:AbortMultipartUpload",
               "s3:GetBucketLocation",
               "s3:GetObject",
               "s3:ListBucket",
               "s3:ListBucketMultipartUploads",
               "s3:PutObject"
            ],
            "Resource": [
              "${aws_s3_bucket.datadog_aws_bucket.arn}",
              "${aws_s3_bucket.datadog_aws_bucket.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "metric_stream_to_firehose" {
  name               = "${var.name}-cloudwatch-to-firehose"
  tags               = local.tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "streams.metrics.cloudwatch.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "metric_stream_to_firehose" {
  name = "${var.name}-cloudwatch-to-firehose"
  role = aws_iam_role.metric_stream_to_firehose.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.datadog_firehose_stream.arn}"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_metric_stream" "datadog_metric_stream" {
  name          = "${var.name}-metric-stream"
  role_arn      = aws_iam_role.metric_stream_to_firehose.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.datadog_firehose_stream.arn
  output_format = "opentelemetry0.7"
  tags          = local.tags
}
