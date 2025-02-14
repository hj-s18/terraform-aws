resource "aws_route_table" "tf_pub_rtb" {
  vpc_id = aws_vpc.tf_vpc.id

  #route {
  #  cidr_block = "0.0.0.0/0"
  #  gateway_id = aws_internet_gateway.tf_igw.id
  #}

  #route {
  #  ipv6_cidr_block        = "::/0"
  #  egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  #}

  tags = {
    Name = "tf_pub_rtb"
  }
}

resource "aws_route" "tf_pub_route_igw" {
  route_table_id = aws_route_table.tf_pub_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.tf_igw.id
}

resource "aws_route_table_association" "tf_pub_sub_1_association" {
  subnet_id      = aws_subnet.tf_pub_sub_1.id
  route_table_id = aws_route_table.tf_pub_rtb.id
}

resource "aws_route_table_association" "tf_pub_sub_2_association" {
  subnet_id      = aws_subnet.tf_pub_sub_2.id
  route_table_id = aws_route_table.tf_pub_rtb.id
}
