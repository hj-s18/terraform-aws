# EKS 노드그룹의 launch temaplate 수정

<br>
<br>
<br>

# 전과 같은 terraform apply 오류 발생함

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

# 문제 원인 예측

예상 문제 원인 1 : launch template 생성 terraform 코드 오류 <br>
예상 문제 원인 2 : 노드그룹 생성 terraform 코드 오류

<br>
<br>
<br>

# 콘솔에 들어가서 문제 원인 파악 1 : launch template

terraform으로 launch template 하나만 만들었는데 두 개 생김

![launch template](https://github.com/user-attachments/assets/c9257c16-7be9-4f57-ae30-c49b856c7b8e)

<br>
<br>
<br>

### 안 만들었는데 생긴 launch template : eks-a0ca8c6e-198f-84d1-d713-eff82d3ec69e

![lt 1](https://github.com/user-attachments/assets/e86f08c9-ea24-4f99-8726-c82bfb505251)

![image](https://github.com/user-attachments/assets/d66d57fa-2a61-4308-839d-4f7a9efa9fb7)

![image](https://github.com/user-attachments/assets/9c83f982-1089-46f4-bd51-b4932526557f)

![image](https://github.com/user-attachments/assets/e41ec20c-babf-4cf7-ab6c-d1509d1806e5)

![image](https://github.com/user-attachments/assets/9a4fd360-e053-47dc-815c-c1d56398cc4b)

![image](https://github.com/user-attachments/assets/91e1d611-21b8-4f13-94ca-57fa6915d24c)

<br>
<br>
<br>

### 두 launch template의 다른점

1. 리소스 태그 없음
2. 고급 세부 정보에 IAM 인스턴스 프로파일 없음, 메타데이터에서 태그 허용부분도 아무것도 없음
3. 템플릿 태그 없음

<br>
<br>
<br>

# 콘솔에 들어가서 문제 원인 파악 2 :  tf-eks-cluster 

terraform 코드로 생성한 노드 그룹 : `tf-eks-managed-node-group` ⇒ 생성 실패 <br>
문제가 노드 그룹 생성 코드에 있다면, 같은 launch template(tf-eks-node-ltXXXX)으로 만들었을 때 노드그룹이 문제없이 생겨야 함 <br>
⇒ ssss라는 이름으로 launch template(tf-eks-node-ltXXXX) 사용해서 노드그룹 생성 ⇒ 생성 실패 <br>
⇒ launch template 없이 노드그룹 생성 (myself) ⇒ 생성 성공 <br>
⇒ 문제 원인 : launch template

![image](https://github.com/user-attachments/assets/fc7a73b3-d981-45f0-b7a3-b56e3a8929af)

![image](https://github.com/user-attachments/assets/eb79f9d7-0df4-4411-a0b6-bd8f2dd3a1f6)

<br>
<br>
<br>

### [참고] 시작 템플릿 없이 노드그룹 생성해도 시작템플릿 하나 생성됨
단, 리소스 태그는 없음 <br>
고급 세부 정보에 IAM 인스턴스 프로파일, 메타데이터에서 태그 허용부분은 있음 <br>
추가 : 고급 세부정보에 사용자 데이터가 있음

![lt-consol](https://github.com/user-attachments/assets/207bf494-09b0-41fd-bfda-8bf68ea40749)

### 결론

위 결과를 살펴보면 다음을 알 수 있음 <br>
1. 시작 템플릿을 만든다면, 리소스 태그는 없어도 되지만, 템플릿 태그는 필요함.
2. 시작 템플릿 없이 노드그룹을 생성해도 시작템플릿이 하나 생성됨

따라서, <br>
1. 태그에 "eks:cluster-name" = "tf-eks-cluster", "eks:nodegroup-name" = "<노드그룹 이름>" 추가해서 시작 템플릿 만들기
2. 시작 템플릿 없이 테라폼 코드 생성

#### 해보기 <br>
1 : 07-eks-6 <br>
2 : 07-eks-5 

<br>
<br>
<br>
