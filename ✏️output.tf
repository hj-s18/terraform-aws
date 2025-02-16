# Bastion Host 정보 출력
output "bastion_public_ip" {
  value = aws_instance.tf_bastion.public_ip
}
