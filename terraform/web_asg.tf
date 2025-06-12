
# terraform/web_asg.tf

resource "aws_launch_template" "web_lt" {
  name_prefix   = "app-tier-lt-"
image_id = "ami-0fa6d4317e4631925"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              cd /home/ec2-user

              # Update and install system tools
              yum update -y
              amazon-linux-extras install epel -y
              yum install -y git curl wget unzip gcc-c++ make

              # Install MySQL client
              wget https://repo.mysql.com/mysql57-community-release-el7-11.noarch.rpm
              rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
              yum install -y mysql57-community-release-el7-11.noarch.rpm
              yum install -y mysql

              # Install NVM and Node.js 16
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
              export NVM_DIR="/home/ec2-user/.nvm"
              source "$NVM_DIR/nvm.sh"
              nvm install 16
              nvm use 16

              # Install PM2
              npm install -g pm2

              # Clone the app code from GitHub
              git clone https://github.com/arditxharri/3tier-app-with-terraform.git
              cd 3tier-app-with-terraform/application-code/app-tier
              npm install

              # Set environment variables (injected by Terraform)
              export DB_HOST="${aws_db_instance.mysql.address}"
              export DB_USER="admin"
              export DB_PASS="Do2025runningAPP"
              export DB_NAME="webappdb"

              # Start the app with PM2 using environment variables
              pm2 start index.js --name app --interpreter bash -- \
                DB_HOST=$DB_HOST DB_USER=$DB_USER DB_PASS=$DB_PASS DB_NAME=$DB_NAME

              # Configure PM2 to auto-start after reboot
              pm2 startup systemd -u ec2-user --hp /home/ec2-user | tee /tmp/pm2-startup.out
              eval $(grep "sudo env" /tmp/pm2-startup.out)
              pm2 save

              # Log health checks
              curl http://localhost:4000/health >> /home/ec2-user/startup-health.log
              curl http://localhost:4000/transaction >> /home/ec2-user/startup-health.log
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-tier-instance"
    }
  }
}


resource "aws_autoscaling_group" "web_asg" {
  name                      = "web-tier-asg"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  vpc_zone_identifier       = [aws_subnet.web_az1.id, aws_subnet.web_az2.id]
  health_check_type         = "ELB"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "web-tier-instance"
    propagate_at_launch = true
  }
}
