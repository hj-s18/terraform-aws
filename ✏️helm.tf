# EKS 클러스터 인증 토큰 생성 ⇒ exec로 참조해서 필요 없음
#data "aws_eks_cluster_auth" "tf_eks_cluster_auth" {
#  name = aws_eks_cluster.tf_eks_cluster.name
#}

# Kubernetes Provider 설정
provider "kubernetes" {
  host                   = aws_eks_cluster.tf_eks_cluster.endpoint
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
    host                   = aws_eks_cluster.tf_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.tf_eks_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.tf_eks_cluster.name]
      command     = "aws"
    }
  }
}

# OIDC Thumbprint 데이터 소스
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
  # enable_cluster_proportional_autoscaler = true
  enable_karpenter                       = true
  enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  # depends_on = [aws_eks_cluster.tf_eks_cluster]

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
