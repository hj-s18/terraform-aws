# RDS DB subnet group resource
resource "aws_db_subnet_group" "tf_rds_subnet_group" {
  name       = "tf-rds-subnet-group"
  subnet_ids = [aws_subnet.tf_rds_sub_1.id, aws_subnet.tf_rds_sub_2.id]

  tags = {
    Name = "tf_rds_subnet_group"
  }
}


# RDS security group
resource "aws_security_group" "tf_rds_sg" {
  name        = "tf-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.tf_vpc.id

  # 관리 목적으로 Bastion Host에서 접근 허용 (필요 시)
  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.tf_bastion_sg.id]
  }

  # EKS managed Node Group에서 접근 허용 추가
  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.tf_eks_node_group_sg.id]
  }

  # RDS의 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_rds_sg"
  }
}

# RDS instance resource. 
resource "aws_db_instance" "tf_rds" {
  allocated_storage           = 20
  engine                      = "mysql"
  username                    = "admin"
  engine_version              = "8.0"
  instance_class              = "db.t3.micro"
  db_name                     = "mydb"
  manage_master_user_password = true   # 이것만 있어도 Secrets Manager 생성됨 (이름이 랜덤 UUID가 포함된 패턴으로 생성됨 : rds!db-<랜덤한_UUID>)
  multi_az                    = true
  vpc_security_group_ids      = [aws_security_group.tf_rds_sg.id]
  db_subnet_group_name        = aws_db_subnet_group.tf_rds_subnet_group.name
  skip_final_snapshot         = true
  storage_type                = "gp3"
  # parameter_group_name        = "default.mysql8.0"

  tags = {
    Name                      = "tf_rds"
  }
}
