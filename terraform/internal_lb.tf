
# Target group for app-tier on port 4000
resource "aws_lb_target_group" "app_tg" {
  name        = "app-tier-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "4000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-tier-tg"
  }
}

# Internal Load Balancer (App Tier)
resource "aws_lb" "lb_internal" {
  name               = "app-internal-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb_sg.id]
  subnets            = [aws_subnet.app_az1.id, aws_subnet.app_az2.id]

  tags = {
    Name = "internal-app-lb"
  }
}

# Listener for App LB
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.lb_internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
