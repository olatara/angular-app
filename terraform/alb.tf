# Configure Load Balancer
resource "aws_lb" "convertr_lb" {
  name = "convertr-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets = [ 
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    aws_default_subnet.default_subnet_c.id
  ]

  depends_on = [aws_lb_target_group.convertr-tg]

  tags = {
    Environment = "production"
  }
}

# Configure IP Target Group
resource "aws_lb_target_group" "convertr-tg" {
  name        = "convertr-tg"
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  health_check {
    matcher = "200"
    path = "/"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.convertr_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.convertr-tg.arn
  }
}