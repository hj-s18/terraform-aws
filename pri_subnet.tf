resource "aws_subnet" "tf_pri_sub_1" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.3.0/24"
  availability_zone      = "ap-northeast-2a
  map_public_ip_on_launch = false # 퍼블릭 IP 주소 자동 할당 : 비활성화 (Default is false)

  tags = {
    Name                 = "tf_pri_sub_1"
  }
}

resource "aws_subnet" "tf_pri_sub_2" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = "10.0.4.0/24"
  availability_zone      = "ap-northeast-2c
  map_public_ip_on_launch = false # 퍼블릭 IP 주소 자동 할당 : 비활성화 (Default is false)

  tags = {
    Name                 = "tf_pri_sub_2"
  }
}

resource "aws_subnet" "tf_rds_sub" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = 10.0.5.0/24
  availability_zone      = "ap-northeast-2a"
  map_public_ip_on_launch = false # 퍼블릭 IP 주소 자동 할당 : 비활성화

  tags = {
    Name = "tf_rds_sub_1"
  }
}

resource "aws_subnet" "tf_rds_sub" {
  vpc_id                 = aws_vpc.tf_vpc.id
  cidr_block             = 10.0.6.0/24
  availability_zone      = "ap-northeast-2c"
  map_public_ip_on_launch = false # 퍼블릭 IP 주소 자동 할당 : 비활성화

  tags = {
    Name = "tf_rds_sub_2"
  }
}
