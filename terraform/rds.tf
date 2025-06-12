# This Terraform configuration sets up an RDS MySQL instance with a subnet group.
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.db_az1.id, aws_subnet.db_az2.id]

  tags = {
    Name = "mysql-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier              = "three-tier-mysql-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100

  db_name                 = var.db_name
  username                = var.db_user
  password                = var.db_pass

  db_subnet_group_name    = aws_db_subnet_group.mysql_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]

  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false

  tags = {
    Name = "mysql-db"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.mysql.db_name
}
