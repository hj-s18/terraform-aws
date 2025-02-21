# 목적

EKS로 배포하는 파드들에 볼륨을 추가하려고 한다. <br>

필요할 때 필요한 만큼 볼륨을 만들어 파드와 연결해주는 방식도 있지만, <br>
서비스를 배포할 때 원하는 볼륨 스펙을 지정해주면 자동으로 볼륨이 생성되어 파드와 연결되는, <br>
동적 방식으로 볼륨이 추가되는 방식을 사용하자.

필요한 에드온을 추가하여 테라폼을 배포하고, 필요한 볼륨을 정해주는 PV, PVC yaml 파일을 만들자. <br>
볼륨과 관련된 에드온 뿐 아니라 Ingress 등 필요한 에드온들도 추가해주자. <br>

이 브랜치는 다음은 필요한 에드온을 추가하여 AWS 리소스들을 배포하는 테라폼 코드이다. <br>
테라폼 코드를 직접 짜기보다 모듈을 이용하는 방식을 사용해볼 예정이다.

<br>

참고자료 <br>
[Helm Provider : Deploy software packages in Kubernetes.](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) <br>
[eks-blueprints-addons : Terraform module to deploy Kubernetes addons on Amazon EKS clusters.](https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest) <br>

<br>
<br>
<br>

# 주의

이 브랜치 clone 후 테라폼 코드 apply 전, 수정해야 할 파일 : [`✏️helm.tf`](https://github.com/hj-s18/terraform-aws/blob/09-addon/%E2%9C%8F%EF%B8%8Fhelm.tf) <br>
module.eks_blueprints_addons.cert_manager_route53_hosted_zone_arns 부분 수동으로 입력해줘야 함 <br>

관련 내용 : [` 📖route53_public.md`](https://github.com/hj-s18/terraform-aws/blob/09-addon/%F0%9F%93%96route53_public.md)

<br>
<br>
<br>

# 계속 나타나는 오류

```
│ Error: execution error at (cluster-proportional-autoscaler/templates/deployment.yaml:3:3): options.target must be one of deployment, replicationcontroller, or replicaset
│
│   with module.eks_blueprints_addons.module.cluster_proportional_autoscaler.helm_release.this[0],
│   on .terraform/modules/eks_blueprints_addons.cluster_proportional_autoscaler/main.tf line 9, in resource "helm_release" "this":
│    9: resource "helm_release" "this" {
│
```

`module.eks_blueprints_addons.eks_addons.enable_cluster_proportional_autoscaler = true`를 사용하면 HPA를 사용하지 않을 수도 있을 것 같아서 하고싶었는데 실패함 <br>

어떤 다른 조건을 추가해야 하는지 모르겠음 <br>
(에드온 추가 코드 아랫부분에서 주석처리된 부분이 이것저것 추가했던 조건들임) <br>

일단 HPA를 반복 사용하면 같은 오토스케일링을 구현할 수도 있을 것 같아서 테라폼 코드에서는 제외하고 진행함 <br>

<br>
<br>
<br>

# Helm 프로바이더

[`✏️eks_cluster.tf`](https://github.com/hj-s18/terraform-aws/blob/09-addon/%E2%9C%8F%EF%B8%8Feks_cluster.tf) 파일 수정 <br>
`aws_eks_cluster.tf_eks_cluster.vpc_config.endpoint_public_access  = true` <br>

컨트롤 플래인이 kubectl과 통신할 때 사용하는 endpoint를 public에서 접근 가능하도록 설정해줘야 Terraform으로 helm 설치 가능함 <br>

<br>
<br>
<br>

# Terraform 코드 실행할 인스턴스에 Helm 설치

```
# Helm 설치
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 설치된 Helm 버전 확인
helm version
```

```
[terraform@ip-192-168-10-138 terraform-aws]$ curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
Downloading https://get.helm.sh/helm-v3.17.1-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
[sudo] password for terraform:
helm installed into /usr/local/bin/helm

[terraform@ip-192-168-10-138 terraform-aws]$ helm version
version.BuildInfo{Version:"v3.17.1", GitCommit:"980d8ac1939e39138101364400756af2bdee1da5", GitTreeState:"clean", GoVersion:"go1.23.5"}
```

<br>
<br>
<br>

# 모듈을 사용할 것이므로 모듈 코드 추가 후 terraform init 다시 해야 함

```
```

<br>
<br>
<br>

# 트러블 슈팅

```
E0221 14:27:52.392528    7311 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"https://XXXX.gr7.ap-northeast-2.eks.amazonaws.com/api?timeout=32s\": dial tcp: lookup XXXX.gr7.ap-northeast-2.eks.amazonaws.com on 192.168.0.2:53: no such host"
```

<br>

- EKS가 완전히 생성 후 Helm provider가 실행되도록 해야 함 
  ⇒ privider에는 depends_on 사용 못함
  ⇒ data source 활용

- data source 사용 X <br>
  ⇒ terraform이 직접 리소스를 생성하고 참조함 <br>
  ⇒ EKS API가 즉시 응답하지 않을 가능성이 있음 <br>

- data source 사용 O <br>
  ⇒ 이미 생성된 리소스를 AWS API에서 조회함 <br>
  ⇒ EKS가 완전히 활성화 된 후 실행됨 ⇒ 안정성이 더 높음 <br>

<br>

```
# data source 추가하기
data "aws_eks_cluster" "tf_eks_cluster" {
  name = aws_eks_cluster.tf_eks_cluster.name
}

# Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.tf_eks_cluster.endpoint   # depends_on 대신 data resource에서 AWS API 조회
  cluster_ca_certificate = base64decode(aws_eks_cluster.tf_eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.tf_eks_cluster.name]
    command     = "aws"
  }
}

# Helm Provider
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.tf_eks_cluster.endpoint   # depends_on 대신 data resource에서 AWS API 조회
    cluster_ca_certificate = base64decode(aws_eks_cluster.tf_eks_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.tf_eks_cluster.name]
      command     = "aws"
    }
  }
}
```

<br>
<br>
<br>

# 참고 : OIDC Thumbprint 데이터 소스 관련 내용

Terraform 최신 버전 (>= 1.3)과 AWS 최신 업데이트를 사용하면 thumbprint_list 없이도 OIDC 프로바이더 생성 가능 (Terraform이 자동으로 처리함) <br>
이전에는 OIDC 프로바이더 설치에 인증서 지문(thumbprint)가 필수였지만, AWS가 업데이트 하면서 OIDC 프로바이더 생성 시 자동으로 인증을 처리하도록 개선됨 <br>

Terraform 공식 문서에서도 thumbprint_list가 선택사항으로 바뀌었음 <br>
AWS 공식 문서에서도 최신 EKS 에서는 OIDC 인증 사용 시 thumbprint가 자동으로 관리됨이 명시되어 있음 <br>

<br>

```
## OIDC Thumbprint 데이터 소스
#data "aws_iam_openid_connect_thumbprint" "eks_thumbprint" {
#  url = aws_eks_cluster.tf_eks_cluster.identity[0].oidc[0].issuer
#}

# OIDC 프로바이더 생성
resource "aws_iam_openid_connect_provider" "tf_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  # thumbprint_list = [data.aws_iam_openid_connect_thumbprint.eks_thumbprint.thumbprint]
  url             = aws_eks_cluster.tf_eks_cluster.identity[0].oidc[0].issuer
}
```

<br>
<br>
<br>

