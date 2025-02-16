resource "aws_route53_zone" "tf_route53_private" {
  name = "tf.private.com"                                  # (Required) The name of the hosted zone.
  vpc {                                                    # (Optional) Configuration block(s) specifying VPC(s) to associate with a private hosted zone. 
    vpc_id = aws_vpc.tf_vpc.id                             # (Required) ID of the VPC to associate.
  }
}

resource "aws_route53_record" "tf_rds_endpoint" {
  zone_id = aws_route53_zone.tf_route53_private.zone_id    # (Required) The ID of the hosted zone to contain this record.
  name    = "rds.tf.private.com"                           # (Required) The name of the record.
  type    = "CNAME"                                        # (Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT.
  ttl     = 300                                            # (Required for non-alias records) The TTL of the record.
  records = [aws_db_instance.tf_rds.address]               # (Required for non-alias records) A string list of records.
}
