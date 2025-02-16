# tls_private_key 생성 (개인 키)
resource "tls_private_key" "tf_bastion_key" {
  algorithm   = "RSA"  # (Required) The name of the algorithm to use for the key. Currently-supported values are "RSA" and "ECDSA".
  rsa_bits  = 2048  # (Optional) When algorithm is "RSA", the size of the generated RSA key in bits. Defaults to 2048.
  # ecdsa_curve = "P384"  # (Optional) When algorithm is "ECDSA", the name of the elliptic curve to use. May be any one of "P224", "P256", "P384" or "P521", with "P224" as the default.
}


# 생성된 키페어 개인 키 pem 형식으로 인코딩하여 로컬로 다운
resource "local_file" "tf_bastion_private_key" {
  content  = tls_private_key.tf_bastion_key.private_key_pem  # The private key data in PEM format.
  filename = "/home/terraform/tf-bastion-key.pem"
  file_permission = "0600"
}


# 생성된 키페어 공개 키 생성
resource "aws_key_pair" "tf_bastion_key" {
  key_name   = "tf-bastion-key"  # (Optional) The name for the key pair. (Default : terraform-XXX)
  public_key = tls_private_key.tf_bastion_key.public_key_openssh  # The public key data in OpenSSH authorized_keys format.

  tags = {
    Name = "tf_bastion_key"
  }
}


# Bastion Security Group
resource "aws_security_group" "tf_bastion_sg" {
  name   = "tf-bastion-sg"
  vpc_id = aws_vpc.tf_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 외부에서 SSH 접속 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_bastion_sg"
  }
}


# Bastion Host EC2 instance
resource "aws_instance" "tf_bastion" {
  ami           = "ami-0a20b1b99b215fb27" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.tf_pub_sub_1.id  # (Optional) VPC Subnet ID to launch in.
  key_name      = aws_key_pair.tf_bastion_key.key_name  # (Optional) Key name of the Key Pair to use for the instance which can be managed using the aws_key_pair resource.
  vpc_security_group_ids = [aws_security_group.tf_bastion_sg.id]
  associate_public_ip_address = true  # 퍼블릭 IP 할당
  
  depends_on = [aws_key_pair.tf_bastion_key]

  tags = {
    Name = "bastion"
  }
}
