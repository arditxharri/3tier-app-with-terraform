# terraform/app_asg.tf

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-tier-asg"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  vpc_zone_identifier       = [aws_subnet.app_az1.id, aws_subnet.app_az2.id]
  health_check_type         = "ELB"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "app-tier-instance"
    propagate_at_launch = true
  }
}
