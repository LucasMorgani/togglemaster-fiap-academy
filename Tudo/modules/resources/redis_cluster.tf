#Redis Security Group. It will allow all trafic from vpc project
resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Allow Postgres from inside VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-redis-sg"
    }
  )
}

#Redis Subnet-group (mandatory)
resource "aws_elasticache_subnet_group" "redis_subnetgroup" {
  name = "redis-subnetgroup"
  subnet_ids = [
    var.private_subnet_1a,
    var.private_subnet_1b
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-redis-subnetgroup"
    }
  )
}


#Elasticache cluster creation
resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id = "cluster-redis"
  description          = "Redis for writer(evaluation/reader(analytics) apps"

  engine         = "redis"
  engine_version = "7.0"
  node_type      = "cache.t4g.small"

  port = 6379

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  parameter_group_name = "default.redis7" #Default config for Redis

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnetgroup.name
  security_group_ids = [aws_security_group.redis_sg.id]
}
