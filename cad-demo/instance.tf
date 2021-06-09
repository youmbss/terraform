provider "aws" {
  region = "ca-central-1" 
  
}
resource "aws_vpc" "Canada-Test-VPC" {
  cidr_block = var.vpc_cidr_block   
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"   

  tags = {
    Name = "${var.env_name}-VPC"
  }
} 

# Public Subnets
resource "aws_subnet" "Canada-Test-subnet-public" {
  vpc_id                  = aws_vpc.Canada-Test-VPC.id
  count                   = length(var.availability_zones)
  cidr_block              = element(var.public_cidr_blocks , count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.availability_zones , count.index) 

  tags = {
    Name = "${var.env_name}-Public-subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "Canada-Test-subnet-private" {
  vpc_id                  = aws_vpc.Canada-Test-VPC.id
  count                   = length(var.availability_zones)
  cidr_block              = element(var.private_cidr_blocks , count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = element(var.availability_zones , count.index) 

  tags = {
    Name = "${var.env_name}-Private-Subnet-${count.index + 1}"
  }
}

#custom Internet Gateway 
resource "aws_internet_gateway" "Canada-Test-gw" {
  vpc_id = aws_vpc.Canada-Test-VPC.id
  tags = {
    Name = "${var.env_name}-gw"
  }
}

#routing table for th custom VPC 
resource "aws_route_table" "Canada-Test-Public-Route-table" {
  vpc_id = aws_vpc.Canada-Test-VPC.id
  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Canada-Test-gw.id
  }
  tags = {
    Name = "${var.env_name}-public-Route-table"
  }
}
#routing association for public subnets
resource "aws_route_table_association" "Canada-Test-public-1-routing-association" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = element(aws_subnet.Canada-Test-subnet-public.*.id , count.index) #Canada-Test-subnet-public
  route_table_id = aws_route_table.Canada-Test-Public-Route-table.id
}

#define private Ip   
resource "aws_eip" "Canada-Test-elastic-ip" {
  count   = length(var.availability_zones)
  vpc     = true
  tags = {
    Name = "${var.env_name}-EIP-${count.index +1}"
  }
}
# creating nat gateway
resource "aws_nat_gateway" "Canada-Test-nat-gw" {
  count          = length(var.availability_zones)
  allocation_id  = element(aws_eip.Canada-Test-elastic-ip.*.id , count.index)
  subnet_id      = element(aws_subnet.Canada-Test-subnet-private.*.id , count.index) 
  depends_on     = [aws_internet_gateway.Canada-Test-gw] 
  tags = {
    Name = "${var.env_name}-nat-gw-${count.index +1}"
  }
}
#creating private route table
resource "aws_route_table" "Canada-Test-Private-Route-table" {
  count            = length(var.availability_zones)
  vpc_id           = aws_vpc.Canada-Test-VPC.id 
  route { 
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.Canada-Test-nat-gw.*.id  , count.index)
  }
  tags = {
    Name = "${var.env_name}-Private-Route-table-${count.index +1}"
  }
}
#routing asssocaiton for priavte subnets
resource "aws_route_table_association" "Canada-Test-private-1-routing-association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.Canada-Test-subnet-private.*.id , count.index)
  route_table_id = element(aws_route_table.Canada-Test-Private-Route-table.*.id , count.index)
}

 
 