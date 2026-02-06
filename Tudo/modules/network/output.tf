output "public_subnet_1a" {
  value = aws_subnet.eks_pub_subnet_1a.id
}

output "public_subnet_1b" {
  value = aws_subnet.eks_pub_subnet_1b.id
}

output "private_subnet_1a" {
  value = aws_subnet.eks_priv_subnet_1a.id
}

output "private_subnet_1b" {
  value = aws_subnet.eks_priv_subnet_1b.id
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.eks_vpc.cidr_block
}