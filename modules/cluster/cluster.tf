#Creating eks cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-cluster"
  role_arn = "arn:aws:iam::449954007039:role/c184285a4776817l12705482t1w449954-LabEksClusterRole-b8ZB1PMZFBNU" # Necessary role (iam.tf)
  version  = "1.31"                                                                                            # K8S version

  vpc_config {
    subnet_ids = [
      var.public_subnet_1a,
      var.public_subnet_1b
    ]
    endpoint_private_access = true # Internal access endpoint
    endpoint_public_access  = true # External access endpoint
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}

#Data to get cluster information. This will be used in the provider.tf file to authenticate and create kubernetes resources
data "aws_eks_cluster" "eks_cluster" {
  #name = "${var.project_name}-cluster"
  name = aws_eks_cluster.eks_cluster.name
}