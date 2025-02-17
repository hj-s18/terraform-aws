# Public Subnet 1
resource "aws_subnet" "tf_pub_sub_1" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf_pub_sub_1"
    "kubernetes.io/role/elb" = "1"             # If you want to deploy load balancers to a public subnet, the subnet must have the following tag
  }
}

resource "aws_subnet" "tf_pub_sub_2" {
  vpc_id = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf_pub_sub_2"
    "kubernetes.io/role/elb" = "1"             # If you want to deploy load balancers to a public subnet, the subnet must have the following tag
    # "kubernetes.io/cluster/tf-eks-cluster" = "shared"  # EKS 클러스터가 퍼블릭 서브넷 사용하고싶다면 추가할 태그
  }
}

# Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}

# Route Table
resource "aws_route_table" "tf_pub_rtb" {
  vpc_id = aws_vpc.tf_vpc.id

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
