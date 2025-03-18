/*
1. Create EC2 resource
2. Create SG:
  - ssh : 22
  - https: 443
  - springboot: 8080

*/

resource "aws_instance" "tf_ec2_instance" {
  ami           = "ami-04b4f1a9cf54c11d0" # ubuntu-image
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "terraform_ec2_key_pair" #stored at ~/.ssh/ on local
  vpc_security_group_ids = [aws_security_group.tf_ec2_sg.id] # associating sg to ec2

  tags = {
    Name = "SpringBoot Application"
  }
}

# security group
resource "aws_security_group" "tf_ec2_sg" {
  name   = "springboot-server-sg"
  description = "SG for Ec2"
  vpc_id = "vpc-0abbcf8e6bf9afc1a" #default vpc

  #inbound rules
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allowing all ips
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allowing all ips
  }

  #for springboot application
  ingress {
    description = "TCP"
    from_port = 8080
    to_port = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allowing all ips

  }

  #outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}