data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-arm64"]
  }
}

resource "aws_security_group" "linux_lab" {
  name        = "linux-lab-sg"
  description = "Linux Lab Security Group"

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "linux-lab-sg"
    Project     = "Linux Lab"
    Environment = "Lab"
    Owner       = "Andrew Timms"
  }
}

resource "aws_key_pair" "linux_lab" {
  key_name   = "linux-lab-key"
  public_key = file(var.public_key_path)

  tags = {
    Name        = "linux-lab-key"
    Project     = "Linux Lab"
    Environment = "Lab"
    Owner       = "Andrew Timms"
  }
}

resource "aws_instance" "linux_lab" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t4g.micro"
  user_data     = <<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

dnf update -y
dnf install nginx -y

systemctl enable nginx
systemctl start nginx

cat <<HTML > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Andy Linux Lab</title>
</head>
<body>
    <h1>Andy Linux Lab</h1>
    <p>Built using Terraform, AWS EC2, Amazon Linux 2023 and Nginx.</p>
    <p>Created by Andy Timms.</p>
</body>
</html>
HTML
EOF

  key_name = aws_key_pair.linux_lab.key_name

  vpc_security_group_ids = [
    aws_security_group.linux_lab.id
  ]

  tags = {
    Name        = "linux-lab"
    Project     = "Linux Lab"
    Environment = "Lab"
    Owner       = "Andrew Timms"
  }
}

resource "aws_eip" "linux_lab" {
  domain = "vpc"

  tags = {
    Name        = "linux-lab-eip"
    Project     = "Linux Lab"
    Environment = "Lab"
    Owner       = "Andrew Timms"
  }
}

resource "aws_eip_association" "linux_lab" {
  instance_id   = aws_instance.linux_lab.id
  allocation_id = aws_eip.linux_lab.id
}