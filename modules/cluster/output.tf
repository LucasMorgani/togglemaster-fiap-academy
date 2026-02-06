# Creating outputs that will go outside the module
output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.id
}
output "oidc" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
output "eks_cluster_sg" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "certificate_authority" {
  value = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_authentic" {
  value = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

