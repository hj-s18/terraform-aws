resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true  # Route 53 Private Hosted Zone 사용 조건

  tags = {
    Name = "tf_vpc"
  }
}
