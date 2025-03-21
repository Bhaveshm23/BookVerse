# rds.tf
/*
1. Create RDS resource
2. Create SG:
  - Port: 5432
  - EC2-SG to communicate with EC2
  - CIDR: Local IP address for security
*/

resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage    = var.rds_allocated_storage
  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  instance_class       = var.rds_instance_class
  identifier           = var.rds_identifier
  db_name              = var.rds_db_name
  username             = var.rds_username
  password             = var.rds_password
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
  skip_final_snapshot  = true
}

resource "aws_security_group" "tf_rds_sg" {
  name   = "rds-postgres-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
#    cidr_blocks     = [var.local_ip]
    security_groups = [aws_security_group.tf_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}