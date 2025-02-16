# Bastion Host 정보 출력
output "bastion_public_ip" {
  value = aws_instance.tf_bastion.public_ip
}

# RDS 정보 출력
output "rds_endpoint" {
  value = aws_route53_record.tf_rds_endpoint.name
}
