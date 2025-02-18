# Launch Template 정의
resource "aws_launch_template" "tf_eks_node_lt" {
  name_prefix   = "tf-eks-node-lt"
  image_id      = "ami-0fa05db9e3c145f63"  # EKS 지원 AMI ID (Amazon Linux 2 AMI)
  instance_type = "t3.medium"

  network_interfaces {
    security_groups = [aws_security_group.tf_eks_node_group_sg.id] 
  }

  block_device_mappings {
    device_name = "/dev/xvda"        # Amazon Linux 2 기본 루트 디바이스
    ebs {
      volume_size = 20               # disk_size 지정
      volume_type = "gp3"            # 최신 EBS 타입
      iops = 3000                    # 기본값 : 3000
      throughput = 125               # 기본값 : 125
    }
  }
}

# AWS eks_node_group 생성
resource "aws_eks_node_group" "tf_eks_managed_node_group" {
  cluster_name    = aws_eks_cluster.tf_eks_cluster.name                       # (Required) Name of the EKS Cluster.
  node_group_name = "tf-eks-managed-node-group"                               # (Optional) Name of the EKS Node Group. If omitted, Terraform will assign a random, unique name. 
  node_role_arn   = aws_iam_role.tf_eks_managed_node_group_iam_role.arn       # (Required) Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
  subnet_ids      = [aws_subnet.tf_pri_sub_1.id, aws_subnet.tf_pri_sub_2.id]  # (Required) Identifiers of EC2 Subnets to associate with the EKS Node Group.

  launch_template {
    id      = aws_launch_template.tf_eks_node_lt.id
    version = "$Latest"
  }

  scaling_config {                     # (Required) Configuration block with scaling settings. 
    desired_size = 3
    max_size     = 5
    min_size     = 3                   # 가용성을 유지하기 위해 최소 3개 이상이 권장됨 ⇒ HA 보장
  }

  capacity_type  = "ON_DEMAND"

  update_config {                      # (Optional) Configuration block with update settings.
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
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

  # EKS 클러스터 → 노드 (Kubelet API 관리)
  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    description     = "Allow cluster to manage worker nodes"  # "Allow EKS control plane to manage nodes" ?
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  # EKS 클러스터 → 노드 (Webhook, API 통신 : API Server)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "Allow cluster to communicate with worker nodes"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  # DNS 요청 허용 (CoreDNS)
  ingress {
    from_port       = 53
    to_port         = 53
    protocol        = "udp"
    description     = "Allow worker nodes to use DNS (UDP)"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  ingress {
    from_port       = 53
    to_port         = 53
    protocol        = "tcp"
    description     = "Allow worker nodes to use DNS (TCP)"
    security_groups = [aws_security_group.tf_eks_cluster_sg.id]
  }

  # 노드 간 통신 (컨테이너 간 트래픽)
  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    description = "Allow node-to-node communication"
    self        = true
  }

  # 노드 → AWS API, ECR, S3 (필수)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow nodes to communicate with AWS services"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 노드 → 외부 DNS 조회 (Amazon DNS or External DNS)
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    description = "Allow nodes to resolve external DNS"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_eks_node_group_sg"
  }
}
