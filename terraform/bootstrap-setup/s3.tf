data "aws_caller_identity" "current" {}
locals{
  bucket-name=coalesce(
    var.s3-bucket-name,
    "taskpilot-tf-state-${data.aws_caller_identity.current.account_id}-${var.aws-region}"
    )
}

resource "aws_s3_bucket" "taskpilot_s3_bucket" {
  bucket              = "${local.bucket-name}"
  force_destroy       = false
  region              = "${var.aws-region}"
  tags                = {
      Name= local.bucket-name
  }
}
resource "aws_s3_bucket_versioning" "taskpilot_s3_bucket_versioning" {
  bucket = aws_s3_bucket.taskpilot_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
