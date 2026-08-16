module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.33"

  endpoint_public_access = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true    # eks creater iam role get administrator permissions
  access_entries = local.access_entries   # if i want to give access to some other user (for now its not required to me)

  # enabled_log_types                      = ["audit", "authenticator"]              # To enable log saving and authentication for control plane
  # cloudwatch_log_group_retention_in_days = 7                                       # Save logs of last 7 days

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets  # private subnet allow outbound traffic which enhances security thats why it is used
  control_plane_subnet_ids = module.vpc.intra_subnets   # intra subnet doesnt allow inbound & outbound traffic thats why it is used

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]

      min_size     = var.node_min_size
      max_size     = var.node_max_size 
      desired_size = var.node_desired_size

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_disk_size
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
    tags = {
      NodeGroup = "default"
    }
  }
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    metrics-server = {}
    aws-ebs-csi-driver = {}
  }
  tags = local.tags
}