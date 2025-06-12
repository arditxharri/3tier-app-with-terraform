# terraform/external_lb.tf

# Target Group for Web Tier on port 80
resource "aws_lb_target_group" "web_tg" {
  name        = "web-tier-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-tier-tg"
  }
}

# External ALB (public facing)
resource "aws_lb" "external_lb" {
  name               = "external-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_lb_sg.id]
  subnets            = [aws_subnet.web_az1.id, aws_subnet.web_az2.id]

  tags = {
    Name = "external-web-lb"
  }
}

# Listener for Web Tier (port 80)
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.external_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
