variable "region" {
  description = "Used to denote region"
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  description = "Used to denote clustername"
  type=string
  default = "taskpilot"
}

variable "kubernetes_version" {
  description = "Used to declare kubernetes version"
  type = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "To denote ec2_instance_type"
  type        = string
  default     = "t2.medium"
}

variable "node_desired_size" {
  description = "Only 1 node required"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum nodes"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Ebs volume size"
  type        = number
  default     = 20
}

variable "postgres_secret_name" {
  description = "Secret manager of postgres credentials"
  type        = string
  default     = "taskpilot/postgres"
}

variable "intern_iam_principal_arn" {
  description = "optional"
  type        = string
  default     = null
}

variable "enable_argocd" {
  description = "Install ArgoCD via Helm from Terraform."
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version. Pinned so a cluster built today matches one built next month."
  type        = string
  default     = "10.3.0"
}