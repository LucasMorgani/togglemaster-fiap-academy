#RDS Security Group. It will allow all trafic from vpc project
resource "aws_security_group" "rds_sg" {
  name        = "rds-togglemaster-sg"
  description = "Allow Postgres from inside VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
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
      Name = "${var.project_name}-rds-auth-service-sg"
    }
  )
}

#RDS Subnet-group (mandatory)
resource "aws_db_subnet_group" "rds_subnetgroup" {
  name       = "rds_subnetgroup"
  subnet_ids = [var.private_subnet_1a, var.private_subnet_1b]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-auth-db-subnet-group"
    }
  )
}

#Creating RDS
#RDS auth-service
resource "aws_db_instance" "postgres_auth_service" {
  identifier = "auth-db"

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "auth_db"
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-auth-service-rds"
    }
  )
}
#RDS flag-service
resource "aws_db_instance" "postgres_flag_service" {
  identifier = "flag-db"

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "flag_db"
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-flag-service-rds"
    }
  )
}
#RDS targeting-service
resource "aws_db_instance" "postgres_targeting_service" {
  identifier = "targeting-db"

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "targeting_db"
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-targeting-service-rds"
    }
  )
}