# Public Subnet 1
resource "aws_subnet" "tf_pub_sub_1" {
  vpc_id = aws_vpc.tf_vpc.id  # (Required) The VPC ID.
  cidr_block = "10.0.1.0/24"  # (Optional) The IPv4 CIDR block for the subnet.
  availability_zone = ap-northeast-2a   # (Optional) AZ for the subnet
  map_public_ip_on_launch = true   # (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.

  tags = {
    Name = "tf_pub_sub_1"
  }
}

resource "aws_subnet" "tf_pub_sub_2" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf_pub_sub_2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id  # (Optional) The VPC ID to create in.

  tags = {
    Name = "tf_igw"
  }
}

# Route Table
resource "aws_route_table" "tf_pub_rtb" {
  vpc_id = aws_vpc.tf_vpc.id  # (Required) The VPC ID.

  tags = {
    Name = "tf_pub_rtb"
  }
}

resource "aws_route" "tf_pub_route_igw" {
  route_table_id = aws_route_table.tf_pub_rtb.id  # (Required) The ID of the routing table.
  destination_cidr_block = "0.0.0.0/0"  # (Optional) The destination CIDR block.
  gateway_id = aws_internet_gateway.tf_igw.id  # (Optional) Identifier of a VPC internet gateway or a virtual private gateway. Specify local when updating a previously imported local route.
}

resource "aws_route_table_association" "tf_pub_sub_1_association" {
  subnet_id      = aws_subnet.tf_pub_sub_1.id  # (Optional) The subnet ID to create an association. Conflicts with gateway_id.
  route_table_id = aws_route_table.tf_pub_rtb.id  # (Required) The ID of the routing table to associate with.
}

resource "aws_route_table_association" "tf_pub_sub_2_association" {
  subnet_id      = aws_subnet.tf_pub_sub_2.id  # (Optional) The subnet ID to create an association. Conflicts with gateway_id.
  route_table_id = aws_route_table.tf_pub_rtb.id  # (Required) The ID of the routing table to associate with.
}
