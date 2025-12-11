# create a VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "murali-vpc"
  }
}

# create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "murali-public-subnet"
  }
}

# create private subnet
resource "aws_subnet" "pvt_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "murali-private-subnet"
  }
}

# create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "murali-igw"
  }
}

# create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "murali-public-rt"
  }
}

# associate public subnet with public route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id 
}

# create a eip
resource "aws_eip" "lb" {
  tags = {
    Name = "murali-eip"
}
}

# create nat gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "murali-gw-NAT"
  }
}

# create private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
  tags = {
    Name = "murali-private-rt"
  }
}

# associate private subnet with private route table
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pvt_subnet.id
  route_table_id = aws_route_table.private_rt.id 
}