# launch template 생성하는 terraform 코드 수정하기

[Terraform 공식문서: Resource aws_launch_template](https://registry.terraform.io/providers/hashicorp/aws/2.40.0/docs/resources/launch_template#network-interfaces)

<br>
<br>
<br>

# 시작 탬플릿 만들 때 리소스 태그 추가하기

![image](https://github.com/user-attachments/assets/2fe088fc-4075-4739-bfe0-886b6b513c19)

<br>
<br>
<br>

# 문제 파악

현재 상황 <br>
1. 시작 템플릿 잘 생성함
2. 시작 템플릿으로 인스턴스도 잘 생성함
3. 노드 그룹 생성에서 오류남 : 콘솔에서 확인해보니 노드그룹에 노드가 없음 <br>

⇒ 노드 그룹이 시작 템플릿으로 만든 인스턴스를 자신의 노드로 인식하지 못함 <br>

⇒ userdata 사용해서 노드그룹이 인식하도록 해줘야 함!

<br>
<br>
<br>

# 전에 수동으로 만들었던 노드그룹에 있던 userdata 확인

환경 변수 설정 → `/etc/eks/bootstrap.sh` 스크립트를 실행하여 노드를 클러스터에 조인 <br>
하는 데 사용되는 bash 스크립트

```
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=<Base64 인코딩된 클러스터 CA 인증서>
API_SERVER_URL=<EKS API 서버 엔드포인트 URL>   # 例: https://XXXX.XXXX.ap-northeast-2.eks.amazonaws.com
K8S_CLUSTER_DNS_IP=<Kubernetes 클러스터 DNS IP 주소>   # 例: 172.20.0.10
/etc/eks/bootstrap.sh tf-eks-cluster --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=ami-0fa05db9e3c145f63,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=tf-eks-managed-node-group --max-pods=17' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP --use-max-pods false

--//--
```

