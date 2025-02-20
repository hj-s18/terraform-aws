# RDS를 사용하는 EKS 서비스 배포해보기

[`08-test-1-eks-nginx`](https://github.com/hj-s18/terraform-aws/tree/08-test-1-eks-nginx) 에서 간단한 nginx를 EKS로 배포해보았다. <br>

다른 여러 AWS 에서 제공하는 서비스들을 사용한 프로젝트 배포에 도전해보자. <br>

우선 EKS와 함께 RDS를 사용하는 서비스를 배포해보자.

<br>
<br>
<br>

# 깃허브에서 k8s 관련 yaml 파일 클론

```
# EKS 컨트롤 플레인에 kubectl 요청 보낼 인스턴스로 이동
ssh -i <key.pem 파일 위치> ec2-user@<퍼블릭 IP>

# 깃허브에서 k8s 관련 yaml 파일 클론
git clone -b 08-test-2-testcode-yaml https://github.com/hj-s18/terraform-aws.git testcode
cd testcode

vi deployment.yaml
---
# ECR에서 가져올 이미지 주소, 태그 수정
# Secrets Manager에서 RDS에 사용하는 보안 암호 이름 확인하여 수정
# 그 외에도 label이나 namespace, 리전 등 수정 (namespace 수정하면 secret.yaml, configmap.yaml 모두 수정해줘야 함)
---

# 사용할 네임스페이스 생성 (안하면 default 네임스페이스 사용)
kubectl create namespace testcode-namespace

# yaml 파일 kubernetes에 배포
kubectl apply -f <실행할 yaml파일>

# 현재 위치에 있는 모든 yaml 파일 kubernetes에 배포
kubectl apply -f .
```

<br>
<br>
<br>

---

<br>

# 테스트 코드 배포해서 rds와 잘 연결되는지 통신 확인하기

```
[ec2-user@ip-10-0-1-172 testcode]$ ls
configmap.yaml  deployment.yaml  secret.yaml


[ec2-user@ip-10-0-1-172 testcode]$ kubectl get ns
NAME              STATUS   AGE
default           Active   30h
kube-node-lease   Active   30h
kube-public       Active   30h
kube-system       Active   30h


[ec2-user@ip-10-0-1-172 testcode]$ kubectl create namespace testcode-namespace
namespace/testcode-namespace created


[ec2-user@ip-10-0-1-172 testcode]$ kubectl get ns
NAME                 STATUS   AGE
default              Active   30h
kube-node-lease      Active   30h
kube-public          Active   30h
kube-system          Active   30h
testcode-namespace   Active   3s


[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -n testcode-namespace
No resources found in testcode-namespace namespace.


[ec2-user@ip-10-0-1-172 testcode]$ kubectl apply -f .
configmap/mysql-config created
deployment.apps/testcode-deployment created
secret/mysql-secret created


[ec2-user@ip-10-0-1-172 testcode]$ kubectl get deployment -n testcode-namespace
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
testcode-deployment   2/2     2            2           91s


[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -o wide -n testcode-namespace
NAME                                   READY   STATUS    RESTARTS   AGE    IP           NODE                                            NOMINATED NODE   READINESS GATES
testcode-deployment-759fd8b8c8-957jx   1/1     Running   0          115s   10.0.4.109   ip-10-0-4-148.ap-northeast-2.compute.internal   <none>           <none>
testcode-deployment-759fd8b8c8-g9ff2   1/1     Running   0          115s   10.0.3.36    ip-10-0-3-117.ap-northeast-2.compute.internal   <none>           <none>
```

<br>
<br>
<br>

# 서비스 생성하기 (ClusterIP)

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl create service clusterip testcode-svc --tcp=8080:5000 -n testcode-namespace --dry-run=client -o yaml > testcode-svc-cip.yaml


[ec2-user@ip-10-0-1-172 testcode]$ ls
configmap.yaml  deployment.yaml  secret.yaml  testcode-svc-cip.yaml


[ec2-user@ip-10-0-1-172 testcode]$ vi testcode-svc-cip.yaml


[ec2-user@ip-10-0-1-172 testcode]$ kubectl apply -f testcode-svc-cip.yaml
service/testcode-svc created
```

<br>
<br>
<br>

# 아직은 페이지 안 뜸

```
# ClusterIP는 클러스터 내부통신용 이므로 테스트 pod 하나 생성 후 들어가서 curl 명령 해보기
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get svc -o wide -n testcode-namespace
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE     SELECTOR
testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   9m32s   app=testcode


[ec2-user@ip-10-0-1-172 testcode]$ kubectl run shell -it --rm --image centos:7 bash
If you don't see a command prompt, try pressing enter.


[root@shell /]# curl 172.20.244.125:8080
^C


[root@shell /]# exit
exit
Session ended, resume using 'kubectl attach shell -c shell -i -t' command when the pod is running
pod "shell" deleted
```

<br>
<br>
<br>

# 파드 로그 확인

⇒ 오류 로그 확인 : Secrets Manager에서 RDS 비밀번호를 가져오는 중 오류 발생

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -n testcode-namespace
NAME                                   READY   STATUS    RESTARTS   AGE
testcode-deployment-759fd8b8c8-957jx   1/1     Running   0          33m
testcode-deployment-759fd8b8c8-g9ff2   1/1     Running   0          33m


[ec2-user@ip-10-0-1-172 testcode]$ kubectl logs testcode-deployment-759fd8b8c8-957jx -n testcode-namespace
[2025-02-20 15:06:33 +0000] [1] [INFO] Starting gunicorn 21.2.0
[2025-02-20 15:06:33 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
[2025-02-20 15:06:33 +0000] [1] [INFO] Using worker: sync
[2025-02-20 15:06:33 +0000] [7] [INFO] Booting worker with pid: 7
[2025-02-20 15:06:33 +0000] [8] [INFO] Booting worker with pid: 8
[2025-02-20 15:06:33 +0000] [7] [INFO] Worker exiting (pid: 7)
Secrets Manager에서 RDS 비밀번호를 가져오는 중 오류 발생: An error occurred (AccessDeniedException) when calling the GetSecretValue operation: User: arn:aws:sts::XXXX:assumed-role/tf-eks-managed-node-role/i-003def7cd9d3c3d2f is not authorized to perform: secretsmanager:GetSecretValue on resource: rds!db-XXXX because no identity-based policy allows the secretsmanager:GetSecretValue action
[2025-02-20 15:06:33 +0000] [8] [INFO] Worker exiting (pid: 8)
...
```

<br>
<br>
<br>

# deployment 지우고 오류 수정 후 다시 배포해야 함

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl delete deployment testcode-deployment -n testcode-namespace
deployment.apps "testcode-deployment" deleted
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
# IAM 정책 파일 생성 (Secrets Manager 접근 권한 가지는 정책)
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

```
[ec2-user@ip-10-0-1-172 testcode]$ ls
configmap.yaml  deployment.yaml  secrets-irsa-policy.json  secret.yaml  testcode-svc-cip.yaml
```

<br>
<br>
<br>

### AWS에 정책 등록

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
 --namespace testcode-namespace \    # 원하는 네임스페이스
 --cluster tf-eks-cluster \          # 사용 중인 EKS 클러스터 이름
 --attach-policy-arn arn:aws:iam::<계정ID>:policy/SecretsManagerIRSAReadPolicy \   # 생성한 정책 Arn
 --approve
```

<br>
<br>
<br>

### 생성된 Service Account 확인

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get serviceaccount -n testcode-namespace
NAME                SECRETS   AGE
default             0         115m
secrets-access-sa   0         62s
```

<br>
<br>
<br>

### Pod에 서비스 계정 적용

생성한 Service Account를 사용할 수 있도록 deployment.yaml 파일에서 Pod에 spec.serviceAccountName 항목 추가

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testcode-deployment
  namespace: testcode-namespace
  labels:
    app: testcode
spec:
  replicas: 2
  selector:
    matchLabels:
      app: testcode
  template:
    metadata:
      labels:
        app: testcode
    spec:
      serviceAccountName: secrets-access-sa    # IRSA 적용 추가
      containers:
      - name: test-container
        ...생략...
```

<br>
<br>
<br>

# 다시 서비스 배포해보기

<br>

### yaml로 파드 배포 → 기본 웹 페이지 확인

```
# yaml 배포
[ec2-user@ip-10-0-1-172 testcode]$ kubectl apply -f deployment.yaml
deployment.apps/testcode-deployment created


# 배포 상태 확인
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get ep -n testcode-namespace
NAME           ENDPOINTS                        AGE
testcode-svc   10.0.3.36:5000,10.0.4.109:5000   41m

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get pods -o wide -n testcode-namespace
NAME                                  READY   STATUS    RESTARTS   AGE     IP           NODE                                            NOMINATED NODE   READINESS GATES
testcode-deployment-6cc546794-96cmg   1/1     Running   0          7m33s   10.0.4.109   ip-10-0-4-148.ap-northeast-2.compute.internal   <none>           <none>
testcode-deployment-6cc546794-9kmks   1/1     Running   0          7m33s   10.0.3.36    ip-10-0-3-117.ap-northeast-2.compute.internal   <none>           <none>

[ec2-user@ip-10-0-1-172 testcode]$ kubectl get svc -o wide -n testcode-namespace
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE   SELECTOR
testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   42m   app=testcode


# 통신 확인
[ec2-user@ip-10-0-1-172 testcode]$ kubectl run shell -it --rm --image centos:7 -n testcode-namespace bash
If you don't see a command prompt, try pressing enter.


[root@shell /]# curl 172.20.244.125:8080

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


# RDS와 연결되어야 볼 수 있는 페이지 접근해보기 : 실패 ⇒ 아직 RDS 연결 안 됨
[root@shell /]# curl 172.20.244.125:8080/items
<!doctype html>
<html lang=en>
<title>500 Internal Server Error</title>
<h1>Internal Server Error</h1>
<p>The server encountered an internal error and was unable to complete your request. Either the server is overloaded or there is an error in the application.</p>


[root@shell /]# exit
exit
```

<br>
<br>
<br>

### RDS 연결 실패 - 원인 : 보안그룹 설정

RDS ↔ 노드 통신 필요 <br>
⇒ RDS에 보안그룹에 노드그룹에서 들어오는 인바운드 규칙 추가하기 <br>

```
# 로그 확인
[ec2-user@ip-10-0-1-172 test]$ kubectl logs flask-app-66f4b576f4-4zf5q
[2025-02-20 15:58:20 +0000] [1] [INFO] Starting gunicorn 21.2.0
[2025-02-20 15:58:20 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
[2025-02-20 15:58:20 +0000] [1] [INFO] Using worker: sync
[2025-02-20 15:58:20 +0000] [7] [INFO] Booting worker with pid: 7
[2025-02-20 15:58:20 +0000] [8] [INFO] Booting worker with pid: 8
[2025-02-20 16:05:01,018] ERROR in app: Exception on /items [GET]
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
<br>
<br>

### RDS 보안그룹에 노드 그룹에서 들어오는 3306포트 인바운드규칙 추가해줌
![image](https://github.com/user-attachments/assets/9a6ca64c-7cff-4da2-a3d3-726e6f526368)

<br>
<br>
<br>

### RDS 연결 성공

```
# 다시 RDS와 연결되어야 볼 수 있는 페이지 접근해보기
[ec2-user@ip-10-0-1-172 testcode]$ kubectl run shell -it --rm --image centos:7 -n testcode-namespace bash
If you don't see a command prompt, try pressing enter.


[root@shell /]# curl 172.20.244.125:8080/items
<h1>저장된 상품 목록</h1><ul><li>Americano - 2000.00원</li></ul><br><a href='/'>상품 추가하기</a>


[root@shell /]# exit
exit
```

```
# pod 다시 실행하고 확인했더니 로그 오류도 없이 잘 통신되고 있음
[ec2-user@ip-10-0-1-172 test]$ kubectl logs flask-app-66f4b576f4-4ntbc
[2025-02-20 15:58:20 +0000] [1] [INFO] Starting gunicorn 21.2.0
[2025-02-20 15:58:20 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
[2025-02-20 15:58:20 +0000] [1] [INFO] Using worker: sync
[2025-02-20 15:58:20 +0000] [7] [INFO] Booting worker with pid: 7
[2025-02-20 15:58:20 +0000] [8] [INFO] Booting worker with pid: 8
```

<br>
<br>
<br>

# 참고 : 다른 namespace에 있어도 통신 가능

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl run shell -it --rm --image centos:7
If you don't see a command prompt, try pressing enter.


[root@shell /]# curl 172.20.244.125:8080

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


[root@shell /]# exit
exit
Session ended, resume using 'kubectl attach shell -c shell -i -t' command when the pod is running
pod "shell" deleted
```

<br>
<br>
<br>

---

# 참고 코드

```
[ec2-user@ip-10-0-1-172 testcode]$ kubectl get all -n testcode-namespace
NAME                                      READY   STATUS    RESTARTS   AGE
pod/testcode-deployment-6cc546794-96cmg   1/1     Running   0          26m
pod/testcode-deployment-6cc546794-9kmks   1/1     Running   0          26m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/testcode-svc   ClusterIP   172.20.244.125   <none>        8080/TCP   60m

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/testcode-deployment   2/2     2            2           26m

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/testcode-deployment-6cc546794   2         2         2       26m


[ec2-user@ip-10-0-1-172 testcode]$ kubectl delete -f .
configmap "mysql-config" deleted
deployment.apps "testcode-deployment" deleted
secret "mysql-secret" deleted
service "testcode-svc" deleted


[ec2-user@ip-10-0-1-172 testcode]$ kubectl get all -n testcode-namespace
No resources found in testcode-namespace namespace.
```

<br>
<br>
<br>

# 참고 : Secrets Manager 이렇게 생성하면 이름도 정할 수 있음
Terraform에서 자동으로 만들면 이름 이상함 <br>

```
aws secretsmanager create-secret --name RDSPassword --secret-string '{"password":"mypassword"}'
```
