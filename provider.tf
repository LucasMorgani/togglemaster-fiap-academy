#AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
  # Creating a backend for the Terraform state to be stored in S3 (Needed for CI/CD)
  backend "s3" {
    bucket = "togglemaster-tfstate"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  # Configuration options
  region  = "us-east-1"
  profile = "fiapaws"
}


data "aws_eks_cluster" "cluster" {
  name       = module.eks_cluster.cluster_name
  depends_on = [module.eks_cluster]
}

#Kubernetes provider to exec a job
provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name", data.aws_eks_cluster.cluster.name,
      "--profile", "fiapaws"
    ]
  }
}