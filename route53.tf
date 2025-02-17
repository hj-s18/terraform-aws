resource "aws_route53_zone" "tf_route53_private" {
  name = "tf.private.com"
  vpc {
    vpc_id = aws_vpc.tf_vpc.id
  }
}

resource "aws_route53_record" "tf_rds_endpoint" {
  zone_id = aws_route53_zone.tf_route53_private.zone_id
  name    = "rds.tf.private.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.tf_rds.address]
}
