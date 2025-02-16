# tls_private_key 생성 (개인 키)
resource "tls_private_key" "tf_bastion_key" {
  algorithm   = "RSA"
}

# 생성된 키페어 개인 키 pem 형식으로 인코딩하여 로컬로 다운
resource "local_file" "tf_bastion_private_key" {
  content  = tls_private_key.tf_bastion_key.private_key_pem
  filename = "/home/terraform/tf-bastion-key.pem"
  file_permission = "0600"
}

# 생성된 키페어 공개 키 생성
resource "aws_key_pair" "tf_bastion_key" {
  key_name   = "tf-bastion-key"
  public_key = tls_private_key.tf_bastion_key.public_key_openssh

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
    cidr_blocks = ["0.0.0.0/0"]
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
  subnet_id     = aws_subnet.tf_pub_sub_1.id
  key_name      = aws_key_pair.tf_bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.tf_bastion_sg.id]
  associate_public_ip_address = true
  
  depends_on = [aws_key_pair.tf_bastion_key]

  tags = {
    Name = "bastion"
  }
}
