# RDS DB subnet group resource
resource "aws_db_subnet_group" "tf_rds_subnet_group" {
  name       = "tf-rds-subnet-group"                                     # (Optional, Forces new resource) The name of the DB subnet group. If omitted, Terraform will assign a random, unique name.
  subnet_ids = [aws_subnet.tf_rds_sub_1.id, aws_subnet.tf_rds_sub_2.id]  # (Required) A list of VPC subnet IDs.

  tags = {
    Name = "tf_rds_subnet_group"
  }
}


# RDS 보안 그룹
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
  allocated_storage           = 20                                             # (Required unless a snapshot_identifier or replicate_source_db is provided) The allocated storage in gibibytes. The amount of allocated storage.
  engine                      = "mysql"                                        # (Required unless a snapshot_identifier or replicate_source_db is provided) The database engine to use.
  username                    = "foo"                                          # (Required unless a snapshot_identifier or replicate_source_db is provided) Username for the master DB user.
  engine_version              = "8.0"                                          # (Optional) The engine version to use.
  instance_class              = "db.t3.micro"                                  # (Required) The instance type of the RDS instance.
  db_name                     = "mydb"                                         # (Optional) The name of the database to create when the DB instance is created. 
  manage_master_user_password = true                                           # (Optional) Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if password is provided.
  # password                  = "foobarbaz"                                    # (Required unless manage_master_user_password is set to true or unless a snapshot_identifier or replicate_source_db is provided or manage_master_user_password is set.) Password for the master DB user. Cannot be set if manage_master_user_password is set to true.
  multi_az                    = true                                           # (Optional) Specifies if the RDS instance is multi-AZ
  publicly_accessible         = false                                          # (Optional) Bool to control if instance is publicly accessible. Default is false.
  vpc_security_group_ids      = [aws_security_group.tf_rds_sg.id]              # (Optional) List of VPC security groups to associate.
  db_subnet_group_name        = aws_db_subnet_group.tf_rds_subnet_group.name   # (Optional) Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default Subnet Group. 
  skip_final_snapshot         = true                                           # (Optional) Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. Default is false.
  storage_type                = "gp3"                                          # (Optional) One of "standard", "gp2", "gp3" (general purpose SSD that needs iops independently), "io1" or "io2". The default is "io1" if iops is specified, "gp2" if not.
  
  tags = {
    Name                      = "tf_rds"
  }
}
