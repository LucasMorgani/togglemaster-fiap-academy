# Private Subnet for the EKS Cluster in us-east-1a
resource "aws_subnet" "eks_priv_subnet_1a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3) # Function to create a subnet within the CIDR Block
  availability_zone = "${data.aws_region.current.id}a"

  tags = merge(
    var.tags,
    {
      Name                              = "${var.project_name}-priv_subnet-1a"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}


# Private Subnet for the EKS Cluster in us-east-1b
resource "aws_subnet" "eks_priv_subnet_1b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 4) # Function to create a subnet within the CIDR Block
  availability_zone = "${data.aws_region.current.id}b"

  tags = merge(
    var.tags,
    {
      Name                              = "${var.project_name}-priv_subnet-1b"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}


# Route table association to the private subnet
resource "aws_route_table_association" "eks_priv_rtb_assoc_1a" {
  subnet_id      = aws_subnet.eks_priv_subnet_1a.id
  route_table_id = aws_route_table.eks_rtb_priv_1a.id
}
resource "aws_route_table_association" "eks_priv_rtb_assoc_1b" {
  subnet_id      = aws_subnet.eks_priv_subnet_1b.id
  route_table_id = aws_route_table.eks_rtb_priv_1b.id
}