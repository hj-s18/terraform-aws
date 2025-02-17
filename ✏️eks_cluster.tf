# EKS Cluster
resource "aws_eks_cluster" "tf_eks_cluster" {
  name = "tf-eks-cluster"                             # (Required) Name of the cluster.
  role_arn = aws_iam_role.eks_cluster_role.arn        # (Required) ARN of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf.
  # version  = "1.31"                                   # (Optional) Desired Kubernetes master version.

  /* access_config {                                     # (Optional) Configuration block for the access config associated with your cluster
    authentication_mode = "API"                       # (Optional) The authentication mode for the cluster. Valid values are CONFIG_MAP, API or API_AND_CONFIG_MAP
  } */
  
  vpc_config {                                        # (Required) Configuration block for the VPC associated with your cluster.

    # (Required) List of subnet IDs. Must be in at least two different availability zones. 
    # Amazon EKS creates cross-account elastic network interfaces in these subnets to allow communication between your worker nodes and the Kubernetes control plane.
    subnet_ids              = [                       # 즉, 컨트롤 플래인과 통신할 ENI가 배치될 서브넷
      aws_subnet.tf_pri_sub_1.id,
      aws_subnet.tf_pri_sub_2.id
    ]

    # (Optional) Whether the Amazon EKS public API server endpoint is enabled. Default is true.
    endpoint_public_access  = false                   # kubectl과 통신할 때 사용하는 endpoint

    # (Optional) Whether the Amazon EKS private API server endpoint is enabled. Default is false.
    endpoint_private_access = true                    # node의 kubelet과 통신할 때 사용하는 endpoint

    # (Optional) List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates to use to allow communication between your worker nodes and the Kubernetes control plane.
    security_group_ids = [
      aws_security_group.tf_eks_cluster_sg.id
    ]
  }

  # Ensure the resource configuration includes explicit dependencies on the IAM Role permissions by adding depends_on if using the aws_iam_role_policy resource or aws_iam_role_policy_attachment resource.
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling. 
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.tf_eks_cluster_policy_AmazonEKSClusterPolicy
  ]
  
  tags = {
    Name = tf_eks_cluster
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
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow bastion to communicate with the cluster API"
    security_groups = [aws_security_group.tf_bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf_eks_cluster_sg"
  }
}
