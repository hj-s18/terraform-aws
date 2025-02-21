# Terraform apply 후 초기 작업

<br>

### ssh 명령으로 생성된 bastion에 접속

```
# terraform output에서 bastion_public_ip를 확인 !
# ~/에서 ssh 명령으로 생성된 bastion에 접속
ssh -i ~/bastion-key.pem ec2-user@<bastion_ip>
```

<br>
<br>
<br>

### aws cli 설정

```
# aws cli 설정
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
```

<br>
<br>
<br>

### kubectl 설치 및 EKS 클러스터와 kubectl 연결

```
# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# EKS 클러스터와 kubectl 연결
aws eks --region ap-northeast-2 update-kubeconfig --name tf-eks-cluster
# cat ~/.kube/config 하면 등록된 내용 볼 수 있음.
```

<br>
<br>
<br>
