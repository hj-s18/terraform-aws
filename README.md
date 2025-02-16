# Bastion Host

![image](https://github.com/user-attachments/assets/97bebd3e-d9f5-4edf-b5da-1fe299e28f25)

```bash
[terraform@ip-192-168-10-138 terraform-aws]$ ssh -i /home/terraform/
aws/                .bash_history       .bashrc             .docker/            .kube/              .ssh/               tf-bastion-key.pem  yaml/
.aws/               .bash_logout        .cache/             .dotnet/            project/            .terraform.d/       .viminfo
awscliv2.zip        .bash_profile       test/               .vscode-server/
[terraform@ip-192-168-10-138 terraform-aws]$ ssh -i /home/terraform/tf-bastion-key.pem ec2-user@<Public_IP>
Are you sure you want to continue connecting (yes/no)? yes
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

6 package(s) needed for security, out of 8 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-10-0-1-46 ~]$

```
<br>
<br>
<br>

## 1. AWS Key pair
### AWS 키페어 생성

<br>

## 2. Bastion Host Security Group
### Bastion Host의 보안 그룹 생성


<br>

## 3. Bastion Host EC2 instance
### Bastion Host로 사용할 EC2 인스턴스 생성

![image](https://github.com/user-attachments/assets/06925f5c-86ee-4170-b31f-b44803702ac4)

<br>
<br>
<br>
