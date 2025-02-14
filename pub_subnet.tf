resource "aws_subnet" "tf_pub_sub_1" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = ap-northeast-2a   # (Optional) AZ for the subnet
  map_public_ip_on_launch = true   # 퍼블릭 IP 주소 자동 할당 : 활성화

  tags = {
    Name = "tf_pub_sub_1"
  }
}

resource "aws_subnet" "tf_pub_sub_2" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true   # 퍼블릭 IP 주소 자동 할당 : 활성화

  tags = {
    Name = "tf_pub_sub_2"
  }
}
