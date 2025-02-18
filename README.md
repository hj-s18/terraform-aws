# terraform-aws

# 참고 : 나는 이렇게 안 만들고 Terraform에서 자동으로 만들었음.. 그랬더니 이름 이상함..

AWS Secrets Manager에 RDS 비밀번호 저장
```
aws secretsmanager create-secret --name RDSPassword --secret-string '{"password":"mypassword"}'
```
