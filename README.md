# RDS 연결 테스트 코드 파드로 실행시키기

```
[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl apply -f configmap.yaml
configmap/mysql-config created
[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl apply -f secret.yaml
secret/mysql-secret created
[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl apply -f deployment.yaml
deployment.apps/flask-app created

[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl get nodes
NAME                                           STATUS   ROLES    AGE    VERSION
ip-10-0-3-83.ap-northeast-2.compute.internal   Ready    <none>   118m   v1.31.5-eks-5                              d632ec
ip-10-0-4-9.ap-northeast-2.compute.internal    Ready    <none>   118m   v1.31.5-eks-5                              d632ec

[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   3h24m

[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
flask-app-7f657f4b8c-7x8fb   1/1     Running   0          7m33s
flask-app-7f657f4b8c-p7ckn   1/1     Running   0          7m33s
```

<br>
<br>
<br>

# 아직은 페이지 안 뜸

```
# 해당 pod로 직접 들어가서 curl 명령 해보기
[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl exec -it flask-app-7f657f4b8c-7x8fb -- /bin/sh
# curl localhost:5000
^C

# 오류 로그 확인 : Secrets Manager에서 RDS 비밀번호를 가져오는 중 오류 발생
[ec2-user@ip-10-0-1-189 terraform-aws]$ kubectl logs flask-app-7f657f4b8c-7x8fb
[2025-02-18 15:02:35 +0000] [1] [INFO] Starting gunicorn 23.0.0
[2025-02-18 15:02:35 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
[2025-02-18 15:02:35 +0000] [1] [INFO] Using worker: sync
[2025-02-18 15:02:35 +0000] [7] [INFO] Booting worker with pid: 7
[2025-02-18 15:02:35 +0000] [8] [INFO] Booting worker with pid: 8
[2025-02-18 15:02:35 +0000] [7] [INFO] Worker exiting (pid: 7)
Secrets Manager에서 RDS 비밀번호를 가져오는 중 오류 발생: An error occurred (AccessDeniedException) when calling the GetSecretValue operation: User: arn:aws:sts::XXXX:assumed-role/tf-eks-managed-node-role/i-0ba4f68615e54a8eb is not authorized to perform: secretsmanager:GetSecretValue on resource: rds!db-XXXX because no identity-based policy allows the secretsmanager:GetSecretValue action
[2025-02-18 15:02:35 +0000] [8] [INFO] Worker exiting (pid: 8)
```
<br>
<br>
<br>

# Secrets Manager 사용할 수 있도록 권한 추가
EKS의 워커 노드(EC2) 또는 파드가 AWS Secrets Manager에서 비밀번호를 가져올 수 있도록 적절한 IAM 권한을 부여해야함

<br>

### 방법1 : IAM 정책 추가

아래 AWS IAM 정책을 tf-eks-managed-node-role에 추가

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:<리전>:<계정ID>:secret:rds!*"
        }
    ]
}
```

- AWS Secrets Manager에서 특정 비밀 값을 읽을 수 있는 권한 부여
- 특정 리전의 특정 계정에 있는 secret에만 적용되는 권한
- 비밀 이름이 "rds!"로 시작하는 모든 secret에 대해 적용

<br>

### 방법2 : IRSA (IAM Role for Service Account) 적용

Pod 단위에서 AWS 리소스에 접근할 수 있도록 IRSA 활용 <br>
⇒ 노드의 모든 pod에 접근 권한이 주어지지 않고 원하는 파드에만 권한을 주어 특정 파드가 직접 AWS 리소스에 접근 가능 <br>
⇒ 특정 Pod에 최소 권한을 적용할 수 있어서 방법1 보다 보안적으로 더 안전함

EKS 클러스터에 IAM OIDC Provider 설정 <br>
⇒ secretsmanager:GetSecretValue 정책 생성 → AWS에 정책 등록 <br>
⇒ 만든 정책을 가지고 서비스 어카운트을 생성 <br>
⇒ 파드가 Secrets Manager에 접근할 수 있는 역할이 생겼음
⇒ 서비스 어카운트를 연결하여 원하는 파드 배포

<br>
<br>
<br>

# 방법2 사용하기 

### EKS 클러스터에 IAM OIDC Provider 설정

```
# eksctl 설치 (Amazon Linux 기준)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# EKS 클러스터에 IAM OIDC Provider 설정
eksctl utils associate-iam-oidc-provider --region=<리전> --cluster=<클러스터ID> --approve
eksctl utils associate-iam-oidc-provider --region=ap-northeast-2 --cluster=tf-eks-cluster --approve
```

<br>
<br>
<br>

### IAM 정책 생성

```
# IAM 정책 생성 (Secrets Manager 접근 권한 가짐)
cat <<EOF > secrets-irsa-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:<리전>:<계정ID>:secret:rds!*"
        }
    ]
}
EOF
```

<br>
<br>
<br>

# 생성한 정책 AWS에 등록

```
# AWS에 정책 등록
aws iam create-policy --policy-name SecretsManagerIRSAReadPolicy --policy-document file://secrets-irsa-policy.json

# 이렇게 출력됨 ⇒ 여기서 Arn 사용할 것임
{
    "Policy": {
        "PolicyName": "SecretsManagerIRSAReadPolicy",
        "PolicyId": "ANPA2JRHDGTB2KJVHB36V",
        "Arn": "arn:aws:iam::<계정ID>:policy/SecretsManagerIRSAReadPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-02-19T20:14:54+00:00",
        "UpdateDate": "2025-02-19T20:14:54+00:00"
    }
}
```

<br>
<br>
<br>

### IAM Role 생성 & EKS의 서비스 계정과 연결

```
# IRSA용 IAM Role을 생성하고, EKS의 서비스 계정과 연결 (위 출력에서 Arn 사용함)
eksctl create iamserviceaccount \
 --name secrets-access-sa \          # 사용할 Service Account 이름 ⇒ deployment에 연결해 줄 것임
 --namespace default \               # 원하는 네임스페이스
 --cluster tf-eks-cluster \          # 사용 중인 EKS 클러스터 이름
 --attach-policy-arn arn:aws:iam::<계정ID>:policy/SecretsManagerIRSAReadPolicy \   # 생성한 정책 Arn
 --approve

# 생성된 Service Account 확인
[ec2-user@ip-10-0-1-172 test]$ kubectl get serviceaccount -n default
NAME                SECRETS   AGE
default             0         12h
secrets-access-sa   0         7m54s
```

<br>
<br>
<br>

### Pod에 서비스 계정 적용

생성한 Service Account를 사용할 수 있도록 Pod에 spec.serviceAccountName 항목 추가

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask
  template:
    metadata:
      labels:
        app: flask
    spec:
      serviceAccountName: secrets-access-sa  # IRSA 적용 추가
      containers:
      - name: test-container
        image: <계정ID>.dkr.ecr.<리전>.amazonaws.com/test-ecr-namespace/test-ecr:latest
        ports:
        - containerPort: 5000
        envFrom:
        - configMapRef:
            name: mysql-config
        env:
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_USER
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_DATABASE
        - name: AWS_SECRET_NAME
          value: "rds!db-XXXX"    # Secrets Manager 이름 : RDS 접근용 password
        - name: AWS_REGION
          value: "ap-northeast-2"
```

<br>
<br>
<br>

# 다시 서비스 배포해보기

```
# yaml 모두 배포
[ec2-user@ip-10-0-1-172 test]$ kubectl apply -f configmap.yaml
configmap/mysql-config created
[ec2-user@ip-10-0-1-172 test]$ kubectl apply -f secret.yaml
secret/mysql-secret created
[ec2-user@ip-10-0-1-172 test]$ kubectl apply -f deployment.yaml
deployment.apps/flask-app created

# 배포 상태 확인
[ec2-user@ip-10-0-1-172 test]$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
flask-app-66f4b576f4-4zf5q   1/1     Running   0          49s
flask-app-66f4b576f4-586rm   1/1     Running   0          49s

# 통신 확인
[ec2-user@ip-10-0-1-172 test]$ kubectl exec -it flask-app-66f4b576f4-4zf5q -- curl localhost:5000
    <h1>상품 관리</h1>
    <form method="POST" action="/add">
        <label for="item">물건 이름:</label><br>
        <input type="text" id="item" name="item"><br>
        <label for="price">가격:</label><br>
        <input type="number" id="price" name="price"><br><br>
        <button type="submit">추가</button>
    </form>
    <br>
    <a href="/items">저장된 상품 보기</a>
```

<br>
<br>
<br>

# RDS 연결 실패 원인 : 보안그룹 설정

RDS ↔ 노드 통신 필요 <br>
⇒ RDS에 보안그룹에 노드그룹에서 들어오는 인바운드 규칙 추가하기 <br>

```
# RDS와 연결되어야 볼 수 있는 페이지 접근해보기 : 실패 ⇒ 아직 RDS 연결 안 됨
[ec2-user@ip-10-0-1-172 test]$ kubectl exec -it flask-app-66f4b576f4-4zf5q -- curl localhost:5000/items
<!doctype html>
<html lang=en>
<title>500 Internal Server Error</title>
<h1>Internal Server Error</h1>
<p>The server encountered an internal error and was unable to complete your request. Either the server is overloaded or there is an error in the application.</p>

# 로그 확인
[ec2-user@ip-10-0-1-172 test]$ kubectl logs flask-app-66f4b576f4-4zf5q
[2025-02-19 20:42:58 +0000] [1] [INFO] Starting gunicorn 23.0.0
[2025-02-19 20:42:58 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
[2025-02-19 20:42:58 +0000] [1] [INFO] Using worker: sync
[2025-02-19 20:42:58 +0000] [7] [INFO] Booting worker with pid: 7
[2025-02-19 20:42:58 +0000] [8] [INFO] Booting worker with pid: 8
[2025-02-19 20:47:01,018] ERROR in app: Exception on /items [GET]
Traceback (most recent call last):
  File "/usr/local/lib/python3.9/site-packages/flask/app.py", line 1511, in wsgi_app
    response = self.full_dispatch_request()
  File "/usr/local/lib/python3.9/site-packages/flask/app.py", line 919, in full_dispatch_request
    rv = self.handle_user_exception(e)
  File "/usr/local/lib/python3.9/site-packages/flask/app.py", line 917, in full_dispatch_request
    rv = self.dispatch_request()
  File "/usr/local/lib/python3.9/site-packages/flask/app.py", line 902, in dispatch_request
    return self.ensure_sync(self.view_functions[rule.endpoint])(**view_args)  # type: ignore[no-any-return]
  File "/app/app.py", line 83, in view_items
    connection.close()
UnboundLocalError: local variable 'connection' referenced before assignment
```

<br>

### RDS 보안그룹에 노드 그룹에서 들어오는 3306포트 인바운드규칙 추가해줌
![image](https://github.com/user-attachments/assets/9a6ca64c-7cff-4da2-a3d3-726e6f526368)


<br>

# RDS 연결 성공

```
# 다시 RDS와 연결되어야 볼 수 있는 페이지 접근해보기
[ec2-user@ip-10-0-1-172 test]$ kubectl exec -it flask-app-66f4b576f4-4ntbc -- curl localhost:5000/items
<h1>저장된 상품 목록</h1><ul><li>Americano - 2000.00원</li></ul><br><a href='/'>상품 추가하기</a>

# pod 다시 실행하고 확인했더니 로그 오류도 없이 잘 통신되고 있음
[ec2-user@ip-10-0-1-172 test]$ kubectl logs flask-app-66f4b576f4-4ntbc
[2025-02-20 02:39:15 +0000] [1] [INFO] Starting gunicorn 23.0.0
[2025-02-20 02:39:15 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
[2025-02-20 02:39:15 +0000] [1] [INFO] Using worker: sync
[2025-02-20 02:39:15 +0000] [7] [INFO] Booting worker with pid: 7
[2025-02-20 02:39:15 +0000] [8] [INFO] Booting worker with pid: 8
```

<br>
<br>
<br>

# 참고 : 나는 Secrets Manager 이렇게 생성하면 이름도 정할 수 있음
Terraform에서 자동으로 만들면 이름 이상함 <br>

```
aws secretsmanager create-secret --name RDSPassword --secret-string '{"password":"mypassword"}'
```
