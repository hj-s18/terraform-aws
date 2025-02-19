# 노드 그룹 테라폼 리소스 코드

## launch_template
(Optional) Configuration block with Launch Template settings. See launch_template below for details. Conflicts with remote_access. <br>

#### `launch_template` Configuration Block <br>
Either id or name must be specified. <br>

`id` - (Optional) Identifier of the EC2 Launch Template. Conflicts with name. <br>

`name` - (Optional) Name of the EC2 Launch Template. Conflicts with id. <br>

`version` - (Required) EC2 Launch Template version number. <br>
While the API accepts values like $Default and $Latest, the API will convert the value to the associated version number (e.g., 1) on read and Terraform will show a difference on next plan. <br>
Using the default_version or latest_version attribute of the aws_launch_template resource or data source is recommended for this argument.

<br>

## remote_access 
(Optional) Configuration block with remote access settings. See remote_access below for details. Conflicts with launch_template. <br>

#### `remote_access` Configuration Block <br>
`ec2_ssh_key` - (Optional) EC2 Key Pair name that provides access for remote communication with the worker nodes in the EKS Node Group. <br>
If you specify this configuration, but do not specify source_security_group_ids when you create an EKS Node Group, either port 3389 for Windows, or port 22 for all other operating systems is opened on the worker nodes to the Internet (0.0.0.0/0). <br>
For Windows nodes, this will allow you to use RDP, for all others this allows you to SSH into the worker nodes. <br>

`source_security_group_ids` - (Optional) Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. <br>
If you specify ec2_ssh_key, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0).

<br>
<br>
<br>

# 아랫부분 잘못 생각해서 진행한 트러블슈팅임..

remote_access는 22번 포트로 노드에 접근할 수 있도록 하는 것임.


<br>
<br>
<br>

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

<br>
<br>
<br>

# ClusterIP

<br>
<br>
<br>

# NodePort

<br>
<br>
<br>

# loadbalancer

### 로드밸런서 타입 service 생성하면 AWS에서 생성하는 lb

![nlb1](https://github.com/user-attachments/assets/1abdf2c2-9674-43ca-a36e-c830b27ef066)

![image](https://github.com/user-attachments/assets/9d819d60-2124-42f2-b9da-29b1db7b4fcd)

![image](https://github.com/user-attachments/assets/f4d8a0a0-4e53-4d35-a8cb-23809070a6bc)

![image](https://github.com/user-attachments/assets/ed967157-6035-4e2c-8bbb-7b10ef5a8b63)

![image](https://github.com/user-attachments/assets/efc5657f-263e-47c3-9e65-9b32c85f6bc9)

<br>
<br>
<br>

# LB 타입 서비스의 External-IP 사용해서 웹페이지 접속 가능

![image](https://github.com/user-attachments/assets/62f4565d-71fe-4e36-86f6-23bc3f1f6793)

<br>
<br>
<br>

# 이렇게 노드그룹 생성했을 때 생성되는 시작 템플릿

연결되어있는 보안그룹 <br>
- eks-cluster-sg-tf-eks-cluster-XXXX (sg-052e81f0c0d710325) <br>
  : EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads. <br>
- eks-remoteAccess-XXXX (sg-0ebca31a77497ba6c) <br>
  : Security group for all nodes in the nodeGroup to allow SSH access <br>

![lt 참고할것](https://github.com/user-attachments/assets/e3627099-0ef2-4a62-8ada-681470866199)

![image](https://github.com/user-attachments/assets/8e53db4b-53fe-4374-9a0a-5e288fe91390)

![image](https://github.com/user-attachments/assets/69e47bee-b844-4de4-a923-1dd478842760)

![image](https://github.com/user-attachments/assets/2c58ef9f-d918-4efb-80d6-2d6ce2f3b5d1)

![image](https://github.com/user-attachments/assets/4291ca3e-3ac4-4226-a84e-007dcb055da9)

![image](https://github.com/user-attachments/assets/9150fa75-fca4-4498-87d9-d9c9ee13b59b)

