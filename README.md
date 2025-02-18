# `07-eks-3` 브랜치 문제 해결 과정 ⇒ 수정된 코드는 `07-eks-3` 브랜치에 반영됨

<br>
<br>
<br>

# 노드그룹 launch template 이미지를 EKS 최적화된 이미지로 변경
```
[ec2-user@ip-192-168-10-138 ~]$ aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.31/amazon-linux-2/recommended/image_id --region ap-northeast-2 --query "Parameter.Value" --output text
ami-0fa05db9e3c145f63
```
 <br>
 <br>
 <br>
 
# 나중에 deployment.yaml 파일 만들 때 Secrets Manager 참조해야 함

RDS 생성할 때 default로 만들어지는 것은 테라폼이 다 만들어지기 전까지 이름을 알 수 없어서 Secrets Manager 새로 만들어서 연결하려고 했음 <br>
그런데 테라폼 코드에서 문법에 맞지 않다고 해서 테라폼 다 만들어진 후 가져와야 함 <br>
terraform 으로 Secrets Manager 생성하면 어떻게 될지 궁금해서 생성해봄 <br>

<br>

```
# AWS Secrests Manager 생성 ⇒ Secrets Manager 이름 정해주기
resource "aws_secretsmanager_secret" "tf_rds_secret" {
  name = "aws/rds/instance/tf_rds"
}
```

![terraform으로 생성한 secrets manager ](https://github.com/user-attachments/assets/d34e27cd-79e2-44e4-8575-5547de3de69a)


<br>
<br>
<br>

# terraform apply 오류 발생
```
╷
│ Error: waiting for EKS Node Group (tf-eks-cluster:tf-eks-managed-node-group) create: unexpected state 'CREATE_FAILED', wanted target 'ACTIVE'. last error: i-023e524808a69bee6, i-026dd6f8309c7c113, i-0f7a818546da46c1e: NodeCreationFailure: Instances failed to join the kubernetes cluster
│
│   with aws_eks_node_group.tf_eks_managed_node_group,
│   on eks_nodegroup.tf line 23, in resource "aws_eks_node_group" "tf_eks_managed_node_group":
│   23: resource "aws_eks_node_group" "tf_eks_managed_node_group" {
│
╵
```

<br>
<br>
<br>

# 클러스터에서 노드그룹 오류 확인

![image](https://github.com/user-attachments/assets/f766a7b4-966f-439d-91f5-921df38e7063)

<br>
<br>
<br>

# 오류 해결방안 찾기

![image](https://github.com/user-attachments/assets/1a2b31bb-490d-4165-83e8-45378fc1f233)

[Amazon EKS 클러스터 및 노드 관련 문제 해결](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/troubleshooting.html) <br>
[클러스터 API 서버 엔드포인트에 대한 네트워크 액세스 제어](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/cluster-endpoint.html#cluster-endpoint-private) <br>

<br>
<br>
<br>

# 오류 해결

07-eks-1 은 terraform apply 했을 때 오류 안 났음 <br>
launch template 생성하여 노드그룹의 보안그룹 생성 후 오류남 <br>
launch template 또는 보안그룹에 문제가 있을 것임 <br>

<br>

모듈로 EKS 생성한 다른 조 보안그룹 그대로 가져옴 <br>
⇒ 07-eks-4 브랜치의 `private_subnet.tf`, `public_subnet.tf`

<br>
<br>
<br>


# 참고 : EKS 클러스터 생성하면 기본적으로 만들어지는 보안그룹

[클러스터에 대한 Amazon EKS 보안 그룹 요구 사항 보기](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html) <br>

### 인바운드 규칙 : 자기 자신
![image](https://github.com/user-attachments/assets/503e1524-6133-41ec-9e63-0b00064c2092)

### 아웃바운드 규칙 : 전체
![image](https://github.com/user-attachments/assets/c21c7bda-507a-4e29-8440-bb3ca38dcb4c)

### 태그
![image](https://github.com/user-attachments/assets/c9ac0535-fb84-4c7a-b9e5-0a764731ae09)
