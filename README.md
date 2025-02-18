# EKS 클러스터, 노드그룹 생성

노드그룹의 보안그룹을 추가하기 위해 launch template 이용하여 노드 그룹 생성

<br>

# 기본
```
# 생성된 bastion에 접속
ssh -i /home/terraform/bastion-key.pem ec2-user@<Bastion Public ID>

# aws cli 설정
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure

# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# EKS 클러스터와 kubectl 연결
aws eks --region ap-northeast-2 update-kubeconfig --name tf-eks-cluster
```

<br>

# .kube/config
```
[ec2-user@ip-10-0-1-100 ~]$ cat .kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: XXXX
    server: https://XXXX.sk1.ap-northeast-2.eks.amazonaws.com  # EKS 클러스터의 API 서버 엔드포인트
  name: arn:aws:eks:ap-northeast-2:<계정ID>:cluster/tf-eks-cluster
contexts:
- context:
    cluster: arn:aws:eks:ap-northeast-2:<계정ID>:cluster/tf-eks-cluster
    user: arn:aws:eks:ap-northeast-2:<계정ID>:cluster/tf-eks-cluster
  name: arn:aws:eks:ap-northeast-2:<계정ID>:cluster/tf-eks-cluster
current-context: arn:aws:eks:ap-northeast-2:<계정ID>:cluster/tf-eks-cluster
kind: Config
preferences: {}
users:
- name: arn:aws:eks:ap-northeast-2:<계정ID>:cluster/tf-eks-cluster
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - ap-northeast-2
      - eks
      - get-token
      - --cluster-name
      - tf-eks-cluster
      - --output
      - json
      command: aws
```

<br>

# 오류남..
```
[ec2-user@ip-10-0-1-100 ~]$ kubectl get nodes
No resources found
```

<br>

# s3잘 나오는 것 보면 AWS 계정 문제는 아님
```
[ec2-user@ip-10-0-1-100 ~]$ aws s3 ls
2025-02-11 06:53:30 do-not-delete-ssm-diagnosis-<계정ID>-ap-northeast-2-l1qrz
```

<br>
