# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0" # Ubuntu AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "terraform_ec2_key_pair"
}

variable "vpc_id" {
  description = "VPC ID for resources"
  type        = string
  default     = "vpc-0abbcf8e6bf9afc1a" # Default VPC
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS (in GB)"
  type        = number
  default     = 10
}

variable "rds_engine" {
  description = "Database engine for RDS"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Engine version for RDS"
  type        = string
  default     = "15"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "bookverse-postgres-db"
}

variable "rds_db_name" {
  description = "Database name for RDS"
  type        = string
  default     = "bookverse"
}

variable "rds_username" {
  description = "RDS database username"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "RDS database password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "local_ip" {
  description = "Local IP address for RDS access"
  type        = string
  default     = "" # Local IP
}