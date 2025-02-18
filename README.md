# test code

MySQL 접근 관련 변수들 EKS Secrets와 ConfigMap, AWS Secrets Manager 사용할 수 있도록 코드 변경 <br>
⇒ EKS yaml 파일에 관련 설정 있음 <br>

<br>
<br>
<br>

# bastion에서 mysql 설치 → RDS 접속 → RDS에 table 생성 → 확인용 데이터 삽입

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

### 例

```
[ec2-user@bastion ~]$ sudo yum update -y
Installed:
  kernel.x86_64 0:5.10.233-224.894.amzn2

Updated:
  aws-cfn-bootstrap.noarch 0:2.0-32.amzn2   python.x86_64 0:2.7.18-1.amzn2.0.10  python-devel.x86_64 0:2.7.18-1.amzn2.0.10  python-libs.x86_64 0:2.7.18-1.amzn2.0.10  python3.x86_64 0:3.7.16-1.amzn2.0.9
  python3-libs.x86_64 0:3.7.16-1.amzn2.0.9  system-release.x86_64 1:2-17.amzn2

Complete!

[ec2-user@bastion ~]$ sudo yum install mysql -y
Installed:
  mariadb.x86_64 1:5.5.68-1.amzn2.0.1

Complete!

[ec2-user@bastion ~]$ mysql -u admin -h <RDS endpoint> -p'<password>'
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

[ec2-user@bastion ~]$
```
