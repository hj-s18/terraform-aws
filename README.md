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
<br>
<br>

참고자료 <br>
[Helm Provider : Deploy software packages in Kubernetes.](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) <br>
[eks-blueprints-addons : Terraform module to deploy Kubernetes addons on Amazon EKS clusters.](https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest) <br>

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

#

<br>
<br>
<br>

# 에드온 추가

<br>
<br>
<br>
