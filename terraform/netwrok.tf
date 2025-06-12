# terraform/network.tf

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "3tier-vpc"
  }
}

# ----------------------------
# Public Subnets (Web Tier)
# ----------------------------
resource "aws_subnet" "web_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-tier-az1"
  }
}

resource "aws_subnet" "web_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-tier-az2"
  }
}

# ----------------------------
# Private Subnets (App Tier)
# ----------------------------
resource "aws_subnet" "app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "app-tier-az1"
  }
}

resource "aws_subnet" "app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "app-tier-az2"
  }
}

# ----------------------------
# Private Subnets (DB Tier)
# ----------------------------
resource "aws_subnet" "db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "db-tier-az1"
  }
}

resource "aws_subnet" "db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "db-tier-az2"
  }
}

# ----------------------------
# Internet Gateway
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "3tier-igw"
  }
}

# ----------------------------
# NAT Gateway (in Web AZ1)
# ----------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_az1.id
  tags = {
    Name = "3tier-nat-gw"
  }
}

# ----------------------------
# Route Tables
# ----------------------------
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Associate public subnets
resource "aws_route_table_association" "web_az1" {
  subnet_id      = aws_subnet.web_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_az2" {
  subnet_id      = aws_subnet.web_az2.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table (for App and DB)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-rt"
  }
}

# Associate private subnets (App + DB)
resource "aws_route_table_association" "app_az1" {
  subnet_id      = aws_subnet.app_az1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "app_az2" {
  subnet_id      = aws_subnet.app_az2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db_az1" {
  subnet_id      = aws_subnet.db_az1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db_az2" {
  subnet_id      = aws_subnet.db_az2.id
  route_table_id = aws_route_table.private.id
}
