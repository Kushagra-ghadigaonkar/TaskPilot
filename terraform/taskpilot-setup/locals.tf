data "aws_caller_identity" "current" { }

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  account_id = data.aws_caller_identity.current.account_id

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  vpc_cidr = "10.0.0.0/16"

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  intra_subnets   = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

  tags = {
    Project   = "taskpilot"
    ManagedBy = "terraform"
    Cluster   = var.cluster_name
  }

  access_entries = var.intern_iam_principal_arn == null ? {} : {
    intern = {
      principal_arn     = var.intern_iam_principal_arn
      type              = "STANDARD"
      kubernetes_groups = ["taskpilot-interns"]
    }
  }
}