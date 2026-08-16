output "bucket_name" {
  description = "Name of the S3 bucket holding the main config's state"
  value       = aws_s3_bucket.taskpilot_s3_bucket.id
}

output "backend_hcl" {
  description = "Ready-to-use backend config. Write it straight to ../backend.hcl: terraform output -raw backend_hcl > ../backend.hcl"

  value = <<-EOT
    bucket = "${aws_s3_bucket.taskpilot_s3_bucket.id}"
    key    = "taskpilot/terraform/bootstrap-setup/terraform.tfstate"
    region = "${var.aws-region}"

    encrypt = true
    use_lockfile = true
  EOT
}