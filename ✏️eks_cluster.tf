# EKS Cluster
resource "aws_eks_cluster" "tf_eks_cluster" {
  name = "tf-eks-cluster"                               # (Required)
  role_arn = aws_iam_role.tf_eks_cluster_iam_role.arn   # (Required)
  version  = "1.31"                                     # (Optional)
  
  vpc_config {                                          # (Required)

    subnet_ids              = [                         # (Required) 컨트롤 플래인과 통신할 ENI가 배치될 서브넷
      aws_subnet.tf_pri_sub_1.id,
      aws_subnet.tf_pri_sub_2.id
    ]

    endpoint_public_access  = false                     # (Optional) kubectl과 통신할 때 사용하는 endpoint
    endpoint_private_access = true                      # (Optional) node의 kubelet과 통신할 때 사용하는 endpoint

    security_group_ids = [                              # (Optional)
      aws_security_group.tf_eks_cluster_sg.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.tf_eks_cluster_policy_AmazonEKSClusterPolicy
  ]
  
  tags = {
    Name = "tf_eks_cluster"
  }
}


# EKS 클러스터 IAM 역할
resource "aws_iam_role" "tf_eks_cluster_iam_role" {
  name = "tf-eks-cluster-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action = "sts:AssumeRole"                      # EKS는 기본적으로 역할(Role) 기반 접근 제어(RBAC)를 사용함
      }
    ]
  })
}

# 클러스터 IAM 정책 연결 - EKS 기본 정책
resource "aws_iam_role_policy_attachment" "tf_eks_cluster_policy_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tf_eks_cluster_iam_role.name
}


# 클러스터 보안그룹
resource "aws_security_group" "tf_eks_cluster_sg" {
  name        = "tf-eks-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = aws_vpc.tf_vpc.id

  # bastion → cluster API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow bastion to communicate with the cluster API"
    security_groups = [aws_security_group.tf_bastion_sg.id]
  }

  # worker nodes → cluster API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow worker nodes to communicate with cluster API"
    security_groups = [aws_security_group.tf_eks_node_group_sg.id]
  }

  # DNS 요청 허용 (CoreDNS)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    description = "Allow worker nodes to use DNS (UDP)"
    self = true
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    description = "Allow worker nodes to use DNS (TCP)"
    self = true
  }

  # worker nodes → worker nodes
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    description = "Allow worker nodes to communicate with the cluster"
    self = true  # 같은 보안 그룹 내부에서 통신 가능
    # security_groups = [aws_security_group.tf_eks_node_group_sg.id]
  }

  #egress {
  #  from_port   = 0
  #  to_port     = 0
  #  protocol    = "-1"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  # EKS Control Plane → 노드 (클러스터 → 노드)
  egress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    description = "Allow cluster to communicate with worker nodes"
    self = true
  }

  # EKS 클러스터 → 인터넷 (ECR, S3, 외부 API 호출 등)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow cluster to communicate with AWS services"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS 요청 허용 (외부 도메인 조회)
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    description = "Allow DNS resolution"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_eks_cluster_sg"
  }
}
