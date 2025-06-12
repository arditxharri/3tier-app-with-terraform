resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-tier-lt-"
image_id = "ami-0fa6d4317e4631925"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              cd /home/ec2-user

              # Update system and install essential tools
              yum update -y
              amazon-linux-extras install epel -y
              yum install -y git curl wget unzip gcc-c++ make

              # Install MySQL client
              wget https://repo.mysql.com//mysql57-community-release-el7-11.noarch.rpm
              rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
              yum install -y mysql57-community-release-el7-11.noarch.rpm
              yum install -y mysql

              # Install NVM + Node.js 16 + PM2
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
              export NVM_DIR="/home/ec2-user/.nvm"
              source "$NVM_DIR/nvm.sh"
              nvm install 16
              nvm use 16
              npm install -g pm2

              # Clone your GitHub repo
              git clone https://github.com/arditxharri/3tier-app-with-terraform.git

              # Go to app-tier directory and start app
              cd 3tier-app-with-terraform/application-code/app-tier
              npm install
              pm2 start index.js

              # Setup PM2 to restart app on reboot
              pm2 startup systemd -u ec2-user --hp /home/ec2-user | tee /tmp/pm2-startup.out
              eval $(grep "sudo env" /tmp/pm2-startup.out)
              pm2 save

             
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-tier-instance"
    }
  }
}
