# ec2.tf
/*
1. Create EC2 resource
2. Create SG:
  - SSH: 22
  - HTTPS: 443
  - SpringBoot: 8080 (optional for testing)
*/

resource "aws_instance" "tf_ec2_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.tf_ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_s3_profile.name
  user_data                   = <<-EOF
              #!/bin/bash
              exec > /home/ubuntu/setup.log 2>&1
              set -x

              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install -y openjdk-17-jdk
              sudo apt install -y git
              sudo apt install -y maven

              cd /home/ubuntu
              git clone https://github.com/Bhaveshm23/BookVerse.git /home/ubuntu/bookverse
              cd /home/ubuntu/bookverse
              sudo chown -R ubuntu:ubuntu /home/ubuntu/bookverse
              pkill -f 'java -jar' || true

              # Generate self-signed SSL certificate
              echo "Generating self-signed SSL certificate..."
              sudo keytool -genkeypair -alias bookverse -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /home/ubuntu/bookverse.p12 -validity 3650 -dname "CN=BookVerse,OU=BookVerse,O=BookVerse,L=Unknown,ST=Unknown,C=Unknown" -storepass bookverse -keypass bookverse

              # Update application.properties with RDS and SSL
              echo "Updating application.properties with RDS and SSL details..."
              sed -i "s|spring.datasource.url=.*|spring.datasource.url=jdbc:postgresql://${aws_db_instance.tf_rds_instance.endpoint}/bookverse|" src/main/resources/application.properties
              sed -i "s|spring.datasource.username=.*|spring.datasource.username=${var.rds_username}|" src/main/resources/application.properties
              sed -i "s|spring.datasource.password=.*|spring.datasource.password=${var.rds_password}|" src/main/resources/application.properties
              sed -i '/server.port/d' src/main/resources/application.properties
              sed -i '/server.ssl/d' src/main/resources/application.properties
              cat << 'SSL_CONFIG' >> src/main/resources/application.properties
              server.port=443
              server.ssl.key-store=/home/ubuntu/bookverse.p12
              server.ssl.key-store-password=bookverse
              server.ssl.key-alias=bookverse
              server.ssl.enabled=true
              SSL_CONFIG

              cat src/main/resources/application.properties >> /home/ubuntu/setup.log

              echo "Starting Maven build..."
              mvn clean package -DskipTests > /home/ubuntu/build.log 2>&1
              echo "Maven build completed. Checking for JAR..."
              ls -l target/ >> /home/ubuntu/setup.log 2>&1
              echo "JAR file expected: target/BookVerse-0.0.1-SNAPSHOT.jar"

              echo "Starting application on port 443..."
              sudo nohup java -jar target/BookVerse-0.0.1-SNAPSHOT.jar > /home/ubuntu/app.log 2>&1 &
              sleep 5
              echo "Application PID: $(pgrep -f 'java -jar')" >> /home/ubuntu/setup.log
              echo "Application started in background. Check /home/ubuntu/app.log for runtime logs."
              EOF

  user_data_replace_on_change = false

  tags = {
    Name = "SpringBoot Application"
  }
}

resource "aws_security_group" "tf_ec2_sg" {
  name        = "springboot-server-sg"
  description = "SG for Ec2"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SpringBoot HTTP (testing)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#s3 access from ec2
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name   = "ec2-s3-policy"
  role   = aws_iam_role.ec2_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "${aws_s3_bucket.tf_bookverse_covers_s3.arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}


output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.tf_ec2_instance.public_ip}"
}