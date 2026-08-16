resource "aws_security_group" "web" {
  name_prefix = "week1-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["174.53.142.69/32"]
  }
  ingress {
  description = "API port for testing"
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["174.53.142.69/32"]  # your IP from before
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "week1-web-sg" }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_name

  tags = { Name = "week1-web-instance" }
}

resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.web.availability_zone
  size              = 8
  tags = { Name = "week1-data-volume" }
}

resource "aws_volume_attachment" "data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.web.id
}