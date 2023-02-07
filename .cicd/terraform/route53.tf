data "aws_route53_zone" "environment_zone" {
  name = "${var.environment}.foodbomb.com.au"
}

resource "aws_route53_record" "ses_dashboard" {
  zone_id = data.aws_route53_zone.environment_zone.zone_id
  name    = "ses-dashboard.${data.aws_route53_zone.environment_zone.name}"
  type    = "CNAME"
  ttl     = "10"
  records = [
    data.aws_lb.main_lb_data.dns_name
  ]
  lifecycle {
    create_before_destroy = true
  }
}
