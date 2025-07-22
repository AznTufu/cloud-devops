# Configuration gratuite avec EC2 t2.micro et Docker Hub

# Data source pour obtenir l'AMI Amazon Linux 2 la plus récente
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instance EC2 t2.micro (Free Tier)
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id             = aws_subnet.public[0].id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    # Attendre que Docker soit prêt
    sleep 10

    # Démarrer les conteneurs avec les variables d'environnement DynamoDB
    docker run -d --name backend --restart unless-stopped -p 3005:3005 \
      -e NODE_ENV=production \
      -e AWS_REGION=${var.region} \
      -e DYNAMODB_TABLE_NAME=${var.app_name}-todos \
      romainparisot/cloud-devops-app-backend:latest
    
    docker run -d --name frontend --restart unless-stopped -p 80:80 romainparisot/cloud-devops-app-frontend:latest
  EOF

  tags = {
    Name = "${var.app_name}-server"
  }
}

# Security Group pour l'EC2
resource "aws_security_group" "app" {
  name        = "${var.app_name}-app-sg"
  description = "Security group for the application server"
  vpc_id      = aws_vpc.main.id

  # HTTP pour le frontend
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend API
  ingress {
    from_port   = 3005
    to_port     = 3005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (optionnel pour debug)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-app-sg"
  }
}
