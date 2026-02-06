# Elastic IP alocate (used by NGW)
resource "aws_eip" "eks_eip_1a" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eip-1a"
    }
  )
}

resource "aws_eip" "eks_eip_1b" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eip-1b"
    }
  )
}


# NAT Gateway for the private subnets
resource "aws_nat_gateway" "eks_ngw_1a" {
  allocation_id = aws_eip.eks_eip_1a.id
  subnet_id     = aws_subnet.eks_pub_subnet_1a.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ngw-1a"
    }
  )
}

resource "aws_nat_gateway" "eks_ngw_1b" {
  allocation_id = aws_eip.eks_eip_1b.id
  subnet_id     = aws_subnet.eks_pub_subnet_1b.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ngw-1b"
    }
  )
}


# Route table for the private subnets
resource "aws_route_table" "eks_rtb_priv_1a" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_ngw_1a.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-priv-rtb-1a"
    }
  )
}

resource "aws_route_table" "eks_rtb_priv_1b" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_ngw_1b.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-priv-rtb-1b"
    }
  )
}
