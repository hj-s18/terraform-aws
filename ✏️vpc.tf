resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = True  # DNS 호스트 이름 활성화해야 VPC 내에서 Route53 CNAME 사용 가능

  tags = {
    Name = "tf_vpc"
  }
}
