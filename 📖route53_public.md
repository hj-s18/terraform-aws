# 도메인 구매 & Route53 Name Space 등록 방법

<br>
<br>
<br>

---

<br>

# 가비아에서 도매인 구매

<br>
<br>
<br>

# AWS Route53 > 호스팅 영역 > 호스팅 영역 생성

- 도메인 이름: <구매한 도매인 이름 입력> <br>
- 유형(Type): 퍼블릭 호스팅 영역(Public Hosted Zone)

<br>

![image](https://github.com/user-attachments/assets/16b1fb59-7684-4997-bd0e-e6a30c410cb6)

<br>
<br>
<br>

# 생성한 호스팅 영역의 Name Space 확인

- AWS Route53 > 호스팅 영역 > 등록한 호스팅 영역 <br>
- NS유형의 값으로 나온 4개의 ns를 가비아에 네임서버로 등록해야 함

<br>

![tkdydgkf](https://github.com/user-attachments/assets/a18c49d8-b584-4dfb-a34c-dc52eaf8371f)

<br>
<br>
<br>

# 가비아에 이름서버 등록

- 가비아의 네임서버를 지우고 Route53의 네임서버(NS) 값으로 교체해야함 <br>

<br>

- 왜 Route 53 네임서버(NS)로 교체해야 하는가? <br>

1. DNS 요청을 Route 53으로 전달하기 위해 필요함 <br>
    - 현재 도메인의 DNS 요청은 가비아의 네임서버를 통해 처리되고 있음 <br>
    - AWS Route 53에서 설정한 A 레코드나 CNAME 레코드 등 DNS 정보를 사용하려면, 도메인의 네임서버를 AWS Route 53의 NS 값으로 변경해야 함 <br>
    - 그렇지 않으면, DNS 요청이 가비아에서 처리되므로 Route 53 설정이 무시됨 <br>

2. 중복 설정 불가능 <br>
    - 네임서버는 한 번에 하나의 DNS 서비스만 처리할 수 있음 <br>
    - 따라서 가비아와 Route 53의 네임서버를 동시에 사용할 수 없음 <br>
    - 기존 가비아 네임서버를 삭제하고 Route 53 네임서버로 교체해야 함 <br>

<br>

![네임서버](https://github.com/user-attachments/assets/cc447579-ed9b-4685-9246-e223a8fa5987)

<br>
<br>
<br>

# 테라폼에서 호스팅 영역 ID 참조

수정해야 할 파일 : [`✏️helm.tf`](https://github.com/hj-s18/terraform-aws/blob/09-addon/%E2%9C%8F%EF%B8%8Fhelm.tf) <br>
module.eks_blueprints_addons.cert_manager_route53_hosted_zone_arns 부분 수동으로 입력해줘야 함 <br>

<br>
<br>
<br>

---

<br>

# Terraform apply 후 로드밸런서 생성하여 Route53에 연결해주기

<br>
<br>
<br>


