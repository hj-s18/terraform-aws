# Single EIP associated with an instance
resource "aws_eip" "tf_eip" {
  domain = "vpc"  # (Optional) Indicates if this EIP is for use in VPC
  
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

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.tf_eip]
}
