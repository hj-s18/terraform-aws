# 노드그룹 생성 오류 났었음 ⇒ `07-eks-5` 브랜치에 바로 수정함

```
╷
│ Error: creating EKS Node Group (tf-eks-cluster:tf-eks-managed-node-group): operation error EKS: CreateNodegroup, https response error StatusCode: 400, RequestID: be40fb27-9af9-4e8c-9b5d-240d35d7cdd0, InvalidParameterException: ec2SshKey in remote-access can't be empty
│
│   with aws_eks_node_group.tf_eks_managed_node_group,
│   on ✏️eks_nodegroup.tf line 25, in resource "aws_eks_node_group" "tf_eks_managed_node_group":
│   25: resource "aws_eks_node_group" "tf_eks_managed_node_group" {
│
╵
```

EKS 노드 그룹에서 SSH 키 페어가 설정되지 않아서 발생한 오류
Launch Template 안 쓰고 보안그룹 사용할 수는 없을까 해서 했는데 안됨
EKS 관리형 노드 그룹(AWS-managed Node Group)을 사용할 때, remote_access 블록을 사용하려면 SSH 키 페어를 지정해야 함

```
# AWS eks_node_group 생성
resource "aws_eks_node_group" "tf_eks_managed_node_group" {
  cluster_name    = aws_eks_cluster.tf_eks_cluster.name                       # (Required)
  node_group_name = "tf-eks-managed-node-group"                               # (Optional)
  node_role_arn   = aws_iam_role.tf_eks_managed_node_group_iam_role.arn       # (Required)
  subnet_ids      = [aws_subnet.tf_pri_sub_1.id, aws_subnet.tf_pri_sub_2.id]  # (Required)

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  instance_types = ["t3.medium"]
  ami_type       = "AL2_x86_64"
  disk_size      = 20
  capacity_type  = "ON_DEMAND"

  remote_access {
    ec2_ssh_key = "my-eks-key"   # SSH 키 페어 필요 (SSH 키 페어 이름 등록하면 됨)
    source_security_group_ids = [aws_security_group.tf_eks_cluster_sg.id]
  }

  update_config {
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
```

