# RDS를 사용하는 EKS 서비스 배포해보기

[`08-test-1-eks-nginx`](https://github.com/hj-s18/terraform-aws/tree/08-test-1-eks-nginx) 에서 간단한 nginx를 EKS로 배포해보았다. <br>
다른 여러 AWS 에서 제공하는 서비스들을 사용한 프로젝트 배포에 도전해보자. <br>

이 브랜치의 `Dockerfile`, `app.py`, `requirements.txt` 파일은 <br>
EKS와 함께 RDS를 사용하는 서비스를 배포해보기 위해 만든 코드이다. <br>

또한 테라폼으로 RDS를 생성하는 코드에서 <br>
Secrets Manager를 사용하여 RDS에 접근할 수 있는 password를 생성하므로 <br>
Secrets Manager에서 password를 불러올 수 있는 변수 설정도 되어있다. <br>

<br>

자세한 설명 : [`📖.md`](https://github.com/hj-s18/terraform-aws/blob/08-test-2-testcode/%F0%9F%93%96.md)

<br>
<br>
<br>
