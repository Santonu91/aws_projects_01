#create vpc
#fetch az data
#create (public)subnet in az0
#create (private) subnet in az.name[0]
#create Internet gateway
#create Route table with route
#create Route table association with public subnet

#Phase 2 (NAT Gateway)
#crate elastic ip
#Create NAT Gateway
#
#create...check 
#its workiing
######################################
######################################

#create vpc
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Custom_vpc"
  }
}
#fetch az data
data "aws_availability_zones" "az" {}
#data "aws_availability_zones" "available" {}

#create (public)subnet in az0

output "az_name" {
  value = data.aws_availability_zones.az.names[0]
}

resource "aws_subnet" "public_subnet" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.custom_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "Public-subnet"

  }
}

resource "aws_subnet" "Private_subnet" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "Private_subnet"
  }
}

#create Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom_internet_gateway"
  }
}

#create Route table with route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

#create Route table association with public subnet
resource "aws_route_table_association" "rt_ass" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

#creation of NAT Gateway
#Create Elastic ip Eip

resource "aws_eip" "Elastic_ip_for_Nat" {
  domain = "vpc"
  tags = {
    Name = "Elastic_ip_for_Nat"
  }

}
#create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.Elastic_ip_for_Nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "Custom_Nat_Gateway"
  }
}

#create private route table to Nat Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "Private_route_table"
  }
}

#create route table association
resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.Private_subnet.id
  route_table_id = aws_route_table.private_route_table.id

}

########
#key pair creation

# provider "tls" {} moved to providor block

resource "tls_private_key" "t" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "tf.key"
  public_key = tls_private_key.t.public_key_openssh

}

#saving the key in local
provider "local" {}

resource "local_file" "key" {
  content  = tls_private_key.t.private_key_pem
  filename = "tf.key.pem"
}

#displaying the output
output "ssh_private_key" {
  value     = tls_private_key.t.private_key_pem
  sensitive = true
}

output "ssh_public_key" {
  value     = tls_private_key.t.public_key_pem
  sensitive = true
}

#security groups and ec2
resource "aws_security_group" "tf_sg1" {
  name        = "tf_sg1"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "http"
    protocol    = "tcp"
    to_port     = 80
    from_port   = 80
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "ssg"
    protocol    = "tcp"
    to_port     = 22
    from_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf_sg1"
  }
}

#########################

#create ec2  wordpress Ami ami-037a09f5091b13557 ,ami-0670736a5b1c3b5d2

resource "aws_instance" "wordpress" {
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids= [aws_security_group.tf_sg1.id]
    ami="ami-0670736a5b1c3b5d2"
    instance_type = "t2.micro"
    key_name = "tf.key"
    tags = {
        Name="Wordpress"
    }
  
}

