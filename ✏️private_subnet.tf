# Subnet (Private)
resource "aws_subnet" "tf_pri_sub_1" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.3.0/24"
  availability_zone      = "ap-northeast-2a"

  tags = {
    Name                                   = "tf_pri_sub_1"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/tf-eks-cluster" = "shared"
  }
}

resource "aws_subnet" "tf_pri_sub_2" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.4.0/24"
  availability_zone      = "ap-northeast-2c"

  tags = {
    Name                                   = "tf_pri_sub_2"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/tf-eks-cluster" = "shared"
  }
}

# Subnet (Private, RDS)
resource "aws_subnet" "tf_rds_sub_1" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.5.0/24"
  availability_zone      = "ap-northeast-2a"

  tags = {
    Name = "tf_rds_sub_1"
  }
}

resource "aws_subnet" "tf_rds_sub_2" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.6.0/24"
  availability_zone      = "ap-northeast-2c"

  tags = {
    Name = "tf_rds_sub_2"
  }
}

# Single EIP associated with an instance
resource "aws_eip" "tf_eip" {
  domain = "vpc"
  
  tags = {
    Name = "tf_eip"
  }
}

# Public NAT
resource "aws_nat_gateway" "tf_nat" {
  allocation_id = aws_eip.tf_eip.allocation_id
  subnet_id     = aws_subnet.tf_pub_sub_2.id

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
