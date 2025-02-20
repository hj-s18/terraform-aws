# test code

MySQL 접근 관련 변수들을 EKS Secrets, ConfigMap 그리고 AWS Secrets Manager 에서 가져와 사용하는 테스트 코드 <br>

⇒ [`08-test-2-testcode-yaml`](https://github.com/hj-s18/terraform-aws/tree/08-test-2-testcode-yaml) 브랜치에 관련 설정 있음 <br>

<br>
<br>
<br>

# Dockerfile로 이미지 생성

```
# 깃 설치
sudo yum install git -y

# 깃허브에서 testcode라는 디렉토리명으로 코드 파일 클론
git clone -b 08-test-2-testcode https://github.com/hj-s18/terraform-aws.git testcode

# 디렉토리로 이동
cd testcode

# 도커파일 사용하여 도커 이미지 빌드
docker build -t testcode .

# 이미지 확인
docker images

---
REPOSITORY      TAG         IMAGE ID         CREATED            SIZE
testcode        latest      76904a4957bd     41 seconds ago     539MB
---

```

# ECR 생성

레포지토리 이름 : test-ecr-namespace/test-ecr

![ecr](https://github.com/user-attachments/assets/a13f6597-f695-420d-9271-2c552eb7a447)

<br>
<br>
<br>

# 생성 완료된 ECR 레포지토리 확인

![ecrtest](https://github.com/user-attachments/assets/b6510dbe-cffd-4e11-ab3e-9222e6c0f948)

<br>
<br>
<br>

# ECR 레포지토리 푸시 명령 사용하여 이미지 ECR에 올리기

```
# 인증 토큰을 검색하고 레지스트리에 대해 Docker 클라이언트 인증
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지에 태그 지정
docker tag testcode:latest <계정ID>.dkr.ecr.<리전>.amazonaws.com/test-ecr-namespace/test-ecr:test

---
REPOSITORY                                                          TAG         IMAGE ID       CREATED          SIZE
<계정ID>.dkr.ecr.<리전>.amazonaws.com/test-ecr-namespace/test-ecr   test        76904a4957bd   22 minutes ago   539MB
testcode                                                            latest      76904a4957bd   22 minutes ago   539MB
---

# ECR 레포지토리에 이미지 푸시
docker push <계정ID>.dkr.ecr.<리전>.amazonaws.com/test-ecr-namespace/test-ecr:latest

---
[terraform@ip-192-168-10-138 testcode]$ docker push <계정ID>.dkr.ecr.<리전>.amazonaws.com/test-ecr-namespace/test-ecr:test
The push refers to repository [<계정ID>.dkr.ecr.<리전>.amazonaws.com/test-ecr-namespace/test-ecr]
...생략...
test: digest: sha256:32c8d4b6f1866b7d69a9e88775b605f0b9c142df47398887cb4c6c14e257f5f0 size: 2206
---

```

<br>
<br>
<br>

# ECR에서 올라간 이미지 확인
![image](https://github.com/user-attachments/assets/7019ab10-9d95-4136-9366-811f9927d32c)

<br>
<br>
<br>

# mysql 설치 → RDS 접속 → table 생성 → 확인용 데이터 삽입

```
# mysql 설치
sudo yum update -y
sudo yum install mysql -y

# RDS 접속
mysql -u admin -h <RDS endpoint> -p'<password>'

# database 확인 후 접속
show databases;
use mydb;

# 테이블 생성
show tables;
CREATE TABLE items (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, price DECIMAL(10, 2) NOT NULL);

# 확인용 데이터 삽입
select * from items;
INSERT INTO items (name, price) VALUES ('Americano', 2000.00);

# RDS에서 빠져나오기
exit
```

<br>
<br>
<br>

## 例

```
[ec2-user@ip-10-0-1-172 ~]$ sudo yum update -y
Installed:
  kernel.x86_64 0:5.10.233-224.894.amzn2

Updated:
  aws-cfn-bootstrap.noarch 0:2.0-32.amzn2   python.x86_64 0:2.7.18-1.amzn2.0.10  python-devel.x86_64 0:2.7.18-1.amzn2.0.10  python-libs.x86_64 0:2.7.18-1.amzn2.0.10  python3.x86_64 0:3.7.16-1.amzn2.0.9
  python3-libs.x86_64 0:3.7.16-1.amzn2.0.9  system-release.x86_64 1:2-17.amzn2

Complete!

[ec2-user@ip-10-0-1-172 ~]$ sudo yum install mysql -y
Installed:
  mariadb.x86_64 1:5.5.68-1.amzn2.0.1

Complete!

[ec2-user@ip-10-0-1-172 ~]$ mysql -u admin -h <RDS endpoint> -p'<password>'
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 55
Server version: 8.0.40 Source distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

MySQL [(none)]> use mydb;
Database changed

MySQL [mydb]> show tables;
Empty set (0.00 sec)

MySQL [testdb]> CREATE TABLE items (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, price DECIMAL(10, 2) NOT NULL);
Query OK, 0 rows affected (0.11 sec)

MySQL [testdb]> show tables;
+------------------+
| Tables_in_testdb |
+------------------+
| items            |
+------------------+
1 row in set (0.00 sec)

MySQL [testdb]> select * from items;
Empty set (0.00 sec)

MySQL [testdb]> INSERT INTO items (name, price) VALUES ('Americano', 2000.00);
Query OK, 1 row affected (0.00 sec)

MySQL [testdb]> select * from items;
+----+-----------+---------+
| id | name      | price   |
+----+-----------+---------+
|  1 | Americano | 2000.00 |
+----+-----------+---------+
1 row in set (0.00 sec)

MySQL [mydb]> exit
Bye

[ec2-user@ip-10-0-1-172 ~]$
```

<br>
<br>
<br>

⇒ [`08-test-2-testcode-yaml`](https://github.com/hj-s18/terraform-aws/tree/08-test-2-testcode-yaml) : k8s로 yaml 파일 배포하기
