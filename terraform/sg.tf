# Configure Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name        = "allow_sgtraffic"

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_sgtraffic"
  }
}
# Configure ECS Service Security Group
resource "aws_security_group" "service_sg" {
  name        = "convertrServicesg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "convertrServicesg"
  }
}