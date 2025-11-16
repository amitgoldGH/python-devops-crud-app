data "aws_secretsmanager_secret_version" "docker" {
  secret_id = "docker_hub_credentials"
}

locals {
  docker_username = jsondecode(data.aws_secretsmanager_secret_version.docker.secret_string).username
  docker_password = jsondecode(data.aws_secretsmanager_secret_version.docker.secret_string).password
}

resource "aws_instance" "flask_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf install -y docker
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker ec2-user

              docker login -u ${local.docker_username} -p ${local.docker_password}
              docker pull ${local.docker_username}/flask-crud-app:latest
              docker run -d -p 5000:5000 ${local.docker_username}/flask-crud-app:latest
              EOF

  tags = {
    Name = "FlaskAppServer"
  }
}

resource "aws_security_group" "flask_sg" {
  name        = "flask-sg"
  description = "Allow HTTP traffic"

  # HTTP (Flask)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
