# terraform/security_groups.tf

# 1. Security Group for External Load Balancer
resource "aws_security_group" "external_lb_sg" {
  name        = "external-lb-sg"
  description = "Allow HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
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

  tags = {
    Name = "external-lb-sg"
  }
}

# 2. Web Tier Security Group (allows traffic from external LB only)
resource "aws_security_group" "web_sg" {
  name        = "web-tier-sg"
  description = "Allow HTTP from external load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from external LB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-tier-sg"
  }
}

# 3. Internal Load Balancer Security Group (allows traffic from Web Tier only)
resource "aws_security_group" "internal_lb_sg" {
  name        = "internal-lb-sg"
  description = "Allow HTTP from web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Web Tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internal-lb-sg"
  }
}

# 4. App Tier Security Group (allows port 4000 from internal LB)
resource "aws_security_group" "app_sg" {
  name        = "app-tier-sg"
  description = "Allow app traffic from internal load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App port from internal LB"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-tier-sg"
  }
}

# 5. Database Security Group (allows MySQL from app tier only)
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from app tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}
