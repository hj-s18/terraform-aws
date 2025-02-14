resource "aws_vpc" "tf_vpc" {
  cidr_block = 10.0.0.0/16   # (Optional) The IPv4 CIDR block for the VPC
  instance_tenancy = "default"   # (Optional) A tenancy option for instances launched into the VPC (Defaults to default)
  enable_dns_support = true   # (Optional) Whether or not the VPC has DNS support (Defaults to true)
  enable_dns_hostnames = false   # (Optional) Whether or not the VPC has DNS hostname support (Defaults to false)

  tags = {
    Name = "tf_vpc"
  }
}
