# Launch Template 정의
resource "aws_launch_template" "tf_eks_node_lt" {
  name_prefix   = "tf-eks-node-lt"
  image_id      = "ami-0fa05db9e3c145f63"  # EKS 지원 AMI ID (Amazon Linux 2 AMI)
  instance_type = "t3.medium"

  vpc_security_group_ids = [aws_security_group.tf_eks_node_group_sg.id] 

  block_device_mappings {
    device_name = "/dev/xvda"        # Amazon Linux 2 기본 루트 디바이스
    ebs {
      volume_size = 20               # disk_size 지정
      volume_type = "gp3"            # 최신 EBS 타입
      iops = 3000                    # 기본값 : 3000 (gp3 기준)
      throughput = 125               # 기본값 : 125 (gp3 기준)
    }
  }

  # 태그 적용
  tags = {
    Name = "tf_eks_node_lt"
    "eks:cluster-name"   = "tf-eks-cluster"
    "eks:nodegroup-name" = "tf-eks-managed-node-group"
  }

  
  # 태그를 tags 블록으로 설정하면 Launch Template 자체에만 적용됨
  # EC2 인스턴스 및 EBS 볼륨에도 적용되도록 tag_specifications 사용해야 함
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                 = "tf_eks_node_lt"
      "eks:cluster-name"   = "tf-eks-cluster"
      "eks:nodegroup-name" = "tf-eks-managed-node-group"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name                 = "tf_eks_node_lt"
      "eks:cluster-name"   = "tf-eks-cluster"
      "eks:nodegroup-name" = "tf-eks-managed-node-group"
    }
  }

  user_data = base64encode(templatefile("userdata.tpl", { CLUSTER_NAME = aws_eks_cluster.tf_eks_cluster.name, B64_CLUSTER_CA = aws_eks_cluster.tf_eks_cluster.certificate_authority[0].data, API_SERVER_URL = aws_eks_cluster.tf_eks_cluster.endpoint, CONTAINER_RUNTIME = "containerd" }))

}

# AWS eks_node_group 생성
resource "aws_eks_node_group" "tf_eks_managed_node_group" {
  cluster_name    = aws_eks_cluster.tf_eks_cluster.name                       # (Required)
  node_group_name = "tf-eks-managed-node-group"                               # (Optional)
  node_role_arn   = aws_iam_role.tf_eks_managed_node_group_iam_role.arn       # (Required)
  subnet_ids      = [aws_subnet.tf_pri_sub_1.id, aws_subnet.tf_pri_sub_2.id]  # (Required)

  launch_template {
    id      = aws_launch_template.tf_eks_node_lt.id
    version = "$Latest"
  }

  scaling_config {                     # (Required)
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  capacity_type  = "ON_DEMAND"

  update_config {                      # (Optional)
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.tf_eks_managed_node_group_policy_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tf_eks_managed_node_group_policy_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tf_eks_managed_node_group_policy_AmazonEC2ContainerRegistryReadOnly,
  ]

tags = {
    Name = "tf_eks_managed_node_group"
  }
}


# 노드 그룹 IAM 역할
resource "aws_iam_role" "tf_eks_managed_node_group_iam_role" {
  name = "tf-eks-managed-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


# 노드 그룹이 EKS 클러스터와 상호작용할 수 있도록 필요한 정책 연결
resource "aws_iam_role_policy_attachment" "tf_eks_managed_node_group_policy_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.tf_eks_managed_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "tf_eks_managed_node_group_policy_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.tf_eks_managed_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "tf_eks_managed_node_group_policy_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.tf_eks_managed_node_group_iam_role.name
}

resource "aws_security_group" "tf_eks_node_group_sg" {
  name        = "tf-eks-node-group-sg"
  description = "EKS Node Group Security Group"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    from_port       = 53
    to_port         = 53
    protocol        = "udp"
    description     = "Node to node CoreDNS UDP"
    self            = true
  }

  ingress {
    from_port       = 53
    to_port         = 53
    protocol        = "tcp"
    description     = "Node to node CoreDNS"
    self            = true
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "Cluster API to node groups"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    description     = "Node to node ingress on ephemeral ports"
    self            = true
  }

  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    description     = "Cluster API to node kubelets"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 4443
    to_port         = 4443
    protocol        = "tcp"
    description     = "Cluster API to node 4443/tcp webhook"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    description     = "Cluster API to node 6443/tcp webhook"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    description     = "Cluster API to node 8443/tcp webhook"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 9443
    to_port         = 9443
    protocol        = "tcp"
    description     = "Cluster API to node 9443/tcp webhook"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_eks_node_group_sg"
  }
}
