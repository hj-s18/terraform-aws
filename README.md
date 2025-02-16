# RDS Secrets Manager 확인
![rds secret manager](https://github.com/user-attachments/assets/f928f4bd-7cf3-4c73-94eb-2be9a06987b4)

# Bastion Host 에서 RDS 접근 확인

```bash
[terraform@terraform terraform-aws]$ ssh -i /home/terraform/tf-bastion-key.pem ec2-user@<Bastion_Public_IP>

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

MySQL [mydb]> exit
Bye

[ec2-user@bastion ~]$
```
