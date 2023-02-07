provider "aws" {
  alias  = "ses_region"
  region = data.aws_ssm_parameter.mailer_region.value
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/fb-pipeline-manager-role"
  }
  default_tags {
    tags = local.default_tags
  }
}

resource "aws_sns_topic_subscription" "email_events_subscription" {
  depends_on = [
    aws_lb_listener_rule.api
  ]
  provider  = aws.ses_region
  topic_arn = data.aws_ssm_parameter.mailer_events_topic_arn.value
  protocol  = "https"
  endpoint  = "https://${aws_route53_record.ses_dashboard.name}/webhook/ses"
}
