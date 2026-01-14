# Creating a Manage Node Group
resource "aws_eks_node_group" "eks_manage_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-node_group"
  node_role_arn   = "arn:aws:iam::449954007039:role/c184285a4776817l12705482t1w449954007-LabEksNodeRole-yJIbh89KbaGa"
  ami_type        = "AL2_x86_64"
  instance_types  = ["t3.medium"]

  subnet_ids = [
    var.private_subnet_1a,
    var.private_subnet_1b
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nodegroup"
    }
  )

  # Defining the desired scling config
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  # Defining dependencies with roles to create and delete them without problems
  #depends_on = [
  #  aws_iam_role_policy_attachment.eks_mng_role_attachment_worker,
  #  aws_iam_role_policy_attachment.eks_mng_role_attachment_cni,
  #  aws_iam_role_policy_attachment.eks_mng_role_attachment_registry,
  #]
}

data "aws_security_groups" "nodegroup_sg" {
  depends_on = [aws_eks_node_group.eks_manage_node_group]

  filter {
    name   = "tag:eks:cluster-name"
    values = [var.cluster_name]
  }

  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.eks_manage_node_group.node_group_name]
  }
}

