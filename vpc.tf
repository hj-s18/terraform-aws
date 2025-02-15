resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf_vpc"
  }
}
