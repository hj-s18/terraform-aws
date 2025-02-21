# EKS가 완전히 생성 후 Helm provider가 실행되도록 하기 위해 data source 활용함 (privider에는 depends_on 사용 못해서 우회하는 방법임)
# data source 사용하지 않으면 terraform이 직접 리소스를 생성하고 참조하므로 EKS API가 즉시 응답하지 않을 가능성이 있음
# data source를 사용하면 이미 생성된 리소스를 AWS API에서 조회함 ⇒ EKS가 완전히 활성화 된 후 실행됨 ⇒ 안정성이 더 높음
data "aws_eks_cluster" "tf_eks_cluster" {
  name = aws_eks_cluster.tf_eks_cluster.name
}

# Kubernetes Provider 설정
provider "kubernetes" {
  host                   = data.aws_eks_cluster.tf_eks_cluster.endpoint   # privider에는 depends_on 사용 못하므로 이렇게 해줌
  cluster_ca_certificate = base64decode(aws_eks_cluster.tf_eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.tf_eks_cluster.name]
    command     = "aws"
  }
}

# Helm Provider 설정
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.tf_eks_cluster.endpoint   # privider에는 depends_on 사용 못하므로 이렇게 해줌
    cluster_ca_certificate = base64decode(aws_eks_cluster.tf_eks_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.tf_eks_cluster.name]
      command     = "aws"
    }
  }
}

# OIDC Thumbprint 데이터 소스
# Terraform 최신 버전 (>= 1.3)과 AWS 최신 업데이트를 사용하면 thumbprint_list 없이도 OIDC 프로바이더 생성 가능 (Terraform이 자동으로 처리함)
# 이전에는 OIDC 프로바이더 설치에 인증서 지문(thumbprint)가 필수였지만, AWS가 업데이트 하면서 OIDC 프로바이더 생성 시 자동으로 인증을 처리하도록 개선됨
# Terraform 공식 문서에서도 thumbprint_list가 선택사항으로 바뀌었음
# AWS 공식 문서에서도 최신 EKS 에서는 OIDC 인증 사용 시 thumbprint가 자동으로 관리됨이 명시되어 있음
#data "aws_iam_openid_connect_thumbprint" "eks_thumbprint" {
#  url = aws_eks_cluster.tf_eks_cluster.identity[0].oidc[0].issuer
#}

# OIDC 프로바이더 생성
resource "aws_iam_openid_connect_provider" "tf_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]  # # AWS에서 사용하는 기본 클라이언트 ID
  # thumbprint_list = [data.aws_iam_openid_connect_thumbprint.eks_thumbprint.thumbprint]
  url             = aws_eks_cluster.tf_eks_cluster.identity[0].oidc[0].issuer
}

module "eks_blueprints_addons" {
  source                 = "aws-ia/eks-blueprints-addons/aws"
  version                = "~> 1.0"

  cluster_name           = aws_eks_cluster.tf_eks_cluster.name
  cluster_endpoint       = aws_eks_cluster.tf_eks_cluster.endpoint
  cluster_version        = "1.31"
  oidc_provider_arn      = aws_iam_openid_connect_provider.tf_oidc_provider.arn

  eks_addons             = {
    aws-ebs-csi-driver   = { most_recent = true }
    coredns              = { most_recent = true }
    vpc-cni              = { most_recent = true }
    kube-proxy           = { most_recent = true }
  }

  enable_aws_load_balancer_controller    = true
  # enable_cluster_proportional_autoscaler = true   # 이것 때문에 terraform apply 가 계속 오류났었음
  enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
  cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/<Route53 → 호스팅 영역 → 사용할 퍼블릭 호스팅 영역 → 호스팅 영역 ID>"]   # 수정해주기

  depends_on = [aws_eks_cluster.tf_eks_cluster]   # EKS 클러스터 생성 후 실행


  # enable_cluster_proportional_autoscaler = true를 사용하면 HPA를 사용하지 않을 수도 있을 것 같아서 하고싶었는데 실패함
  # 어떤 다른 조건을 추가해야 하는지 모르겠음 (아래 주석처리 부분이 이것저것 추가했던 조건들임)
  /* 
  cluster_proportional_autoscaler = {
    nameOverride            = "kube-dns-autoscaler"
    config                  = {
      linear                = {
        coresPerReplica     = 256
        nodesPerReplica     = 16
        min                 = 1
        max                 = 100
      }
    }
    options                 = {
      target                = "deployment/coredns"
    }
  }
  */


  tags                                   = {
    Environment                          = "dev"
  }
}
