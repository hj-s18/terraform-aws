# RDS를 사용하는 EKS 서비스 배포

[`08-test-1-eks-nginx`](https://github.com/hj-s18/terraform-aws/tree/08-test-1-eks-nginx) 에서 간단한 nginx를 EKS로 배포해보았다. <br>
다른 여러 AWS 에서 제공하는 서비스들을 사용한 프로젝트 배포에 도전해보자. <br>

우선 EKS와 함께 RDS를 사용하는 서비스를 배포해보자. <br>
또한 테라폼으로 RDS를 생성하는 코드에서 Secrets Manager를 사용하여 RDS에 접근할 수 있는 password를 생성하므로 Secrets Manager에 접근할 수 있는 권한도 필요하다. <br>
노드그룹과 RDS가 어떻게 통신해야 하는지, 서비스가 RDS에 접근할 때 Secrets Manager에서 password를 어떻게 가져올 것인지 생각해보자. <br>

자세한 설명 : [📖.md](https://github.com/hj-s18/terraform-aws/blob/08-test-2-testcode-yaml/%F0%9F%93%96.md)

<br>
<br>
<br>
