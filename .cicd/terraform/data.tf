data "aws_vpc" "main" {
  filter {
    name   = "tag:aws:cloudformation:stack-name"
    values = [format("EC2ContainerService-%s", local.ecs_cluster_name)]
  }
}

data "aws_ecs_cluster" "main" {
  cluster_name = local.ecs_cluster_name
}

data "aws_lb" "main_lb_data" {
  name = local.alb_name
}

data "aws_lb_listener" "listener_443" {
  load_balancer_arn = data.aws_lb.main_lb_data.arn
  port              = 443
}

data "aws_ssm_parameter" "mailer_ssh_default_path" {
  name = "/${var.environment}/mailer-ssm-default-path"
}

data "aws_ssm_parameter" "mailer_access_key_id" {
  name = "${data.aws_ssm_parameter.mailer_ssh_default_path.value}/ACCESS_KEY_ID"
}

data "aws_ssm_parameter" "mailer_access_key_secret" {
  name = "${data.aws_ssm_parameter.mailer_ssh_default_path.value}/ACCESS_KEY_SECRET"
}

data "aws_ssm_parameter" "mailer_region" {
  name = "${data.aws_ssm_parameter.mailer_ssh_default_path.value}/REGION"
}

data "aws_ssm_parameter" "mailer_default_configuration_set" {
  name = "${data.aws_ssm_parameter.mailer_ssh_default_path.value}/DEFAULT_CONFIGURATION_SET"
}

data "aws_ssm_parameter" "mailer_events_topic_arn" {
  name = "${data.aws_ssm_parameter.mailer_ssh_default_path.value}/MAIL_EVENTS_TOPIC_ARN"
}

data "aws_ecr_repository" "ses_dashboard" {
  name = "ses-dashboard"
}
