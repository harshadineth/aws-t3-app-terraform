# Create s3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "webapp-bucket-harsha-t3-app"  # Ensure this is globally unique
  tags = {
    Name = "webapp"
  }
}

# Create iam role for EC2 to and assinging permissions
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_Iam_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "app_vpc"
  }
}

# Create Subnets
resource "aws_subnet" "web_AZ-1_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.web_AZ-1
  availability_zone = var.az_1
  tags = {
    Name = "web_AZ-1_subnet"
  }
}
resource "aws_subnet" "web_AZ-2_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.web_AZ-2
  availability_zone = var.az_2
  tags = {
    Name = "web_AZ-2_subnet"
  }
}
resource "aws_subnet" "app_AZ-1_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.app_AZ-1
  availability_zone = var.az_1
  tags = {
    Name = "app_AZ-1_subnet"
  }
}
resource "aws_subnet" "app_AZ-2_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.app_AZ-2
  availability_zone = var.az_2
  tags = {
    Name = "app_AZ-2_subnet"
  }
}
resource "aws_subnet" "db_AZ-1_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.db_AZ-1
  availability_zone = var.az_1
  tags = {
    Name = "db_AZ-1_subnet"
  }
}
resource "aws_subnet" "db_AZ-2_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.db_AZ-2
  availability_zone = var.az_2
  tags = {
    Name = "db_AZ-2_subnet"
  }
}

# Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app_vpc_igw"
  }
}

# Allocate Elastic IPs
resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.web_AZ-1_subnet.id
  tags = {
    Name = "nat_gw_az1"
  }
}

resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.web_AZ-2_subnet.id  
  tags = {
    Name = "nat_gw_az2"
  }
}

# Create Route Tables

resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.app_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
 
 tags = {
   Name = "Public_Subnet_RT"
 }
}

# Associate the subnets with the public route table
resource "aws_route_table_association" "public_rt_association_az1" {
  subnet_id      = aws_subnet.web_AZ-1_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_az2" {
  subnet_id      = aws_subnet.web_AZ-2_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt_az1" {
 vpc_id = aws_vpc.app_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.nat_gw_az1.id  
 }
 
 tags = {
   Name = "AZ1_RT"
 }
}

resource "aws_route_table" "private_rt_az2" {
 vpc_id = aws_vpc.app_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.nat_gw_az2.id  
 }
 
 tags = {
   Name = "AZ2_RT"
 }
}

# Associate the subnets with the public route table
resource "aws_route_table_association" "private_rt_association_az1" {
  subnet_id      = aws_subnet.app_AZ-1_subnet.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table_association" "private_rt_association_az2" {
  subnet_id      = aws_subnet.app_AZ-2_subnet.id
  route_table_id = aws_route_table.private_rt_az2.id
}

