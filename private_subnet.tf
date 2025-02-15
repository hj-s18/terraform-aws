# Subnet (Private)
resource "aws_subnet" "tf_pri_sub_1" {
  vpc_id                 = aws_vpc.tf_vpc.id  # (Required) The VPC ID.
  cidr_block             = "10.0.3.0/24"  # (Optional) The IPv4 CIDR block for the subnet.
  availability_zone      = "ap-northeast-2a"  # (Optional) AZ for the subnet.
  map_public_ip_on_launch = false   # (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.

  tags = {
    Name                 = "tf_pri_sub_1"
  }
}

resource "aws_subnet" "tf_pri_sub_2" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.4.0/24"
  availability_zone      = "ap-northeast-2c"
  map_public_ip_on_launch = false

  tags = {
    Name                 = "tf_pri_sub_2"
  }
}

# Subnet (Private, RDS)
resource "aws_subnet" "tf_rds_sub_1" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.5.0/24"
  availability_zone      = "ap-northeast-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "tf_rds_sub_1"
  }
}

resource "aws_subnet" "tf_rds_sub_2" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.6.0/24"
  availability_zone      = "ap-northeast-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "tf_rds_sub_2"
  }
}

# Single EIP associated with an instance
resource "aws_eip" "tf_eip" {
  domain = "vpc"  # (Optional) Indicates if this EIP is for use in VPC.
  
  tags = {
    Name = "tf_eip"
  }
}

# Public NAT
resource "aws_nat_gateway" "tf_nat" {
  allocation_id = aws_eip.tf_eip.allocation_id  # (Optional) The Allocation ID of the Elastic IP address for the NAT Gateway. Required for connectivity_type of public.
  subnet_id     = aws_subnet.tf_pub_sub_2.id  # (Required) The Subnet ID of the subnet in which to place the NAT Gateway.
  depends_on = [aws_eip.tf_eip]

  tags = {
    Name = "tf_nat"
  }
}

# Route Table (Private)
resource "aws_route_table" "tf_pri_rtb" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_pri_rt"
  }
}

resource "aws_route" "tf_pri_route_nat" {
  route_table_id = aws_route_table.tf_pri_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.tf_nat.id
}

resource "aws_route_table_association" "tf_pri_sub_1_association" {
  subnet_id      = aws_subnet.tf_pri_sub_1.id
  route_table_id = aws_route_table.tf_pri_rtb.id
}

resource "aws_route_table_association" "tf_pri_sub_2_association" {
  subnet_id      = aws_subnet.tf_pri_sub_2.id
  route_table_id = aws_route_table.tf_pri_rtb.id
}

resource "aws_route_table_association" "tf_rds_sub_1_association" {
  subnet_id      = aws_subnet.tf_rds_sub_1.id
  route_table_id = aws_route_table.tf_pri_rtb.id
}

resource "aws_route_table_association" "tf_rds_sub_2_association" {
  subnet_id      = aws_subnet.tf_rds_sub_2.id
  route_table_id = aws_route_table.tf_pri_rtb.id
}
