locals {
  management_account_id = var.aws_account_id
  region                = "ap-southeast-2"
  default_tags = {
    project    = "mailer"
    app_name   = var.app_name
    env        = var.environment
    namespace  = var.namespace
    cluster    = var.environment
    app_name   = var.app_name
    managed_by = "terraform"
    tier : "application"
    git_repository = "github.com:foodbomb/sesdashboard.git"
  }
}

provider "aws" {
  region = local.region

  assume_role {
    role_arn = "arn:aws:iam::${local.management_account_id}:role/fb-pipeline-manager-role"
  }

  default_tags {
    tags = local.default_tags
  }
}

locals {
  ecs_cluster_name = var.environment != "production" ? "Foodbomb-dev" : "PROD-Foodbomb"
  alb_name         = var.environment != "production" ? "ecs-alb" : "PROD-FOODBOMB-ALB"
  default_prefix   = replace("${var.app_name}-${var.environment}", "_", "-")
  ssm_default_prefix = replace(
    join("/", [
      "",
      local.ecs_cluster_name,
      var.environment
    ]), "_", "-"
  )
  ssm_ses_dashboard_prefix = replace("${local.ssm_default_prefix}/${var.app_name}", "_", "-")
  dashboard_admin_email    = "ses+${var.environment}@foodbomb.com.au"
  dashboard_admin_name     = "SesDashboard"
}

resource "random_password" "dashboard_user_password" {
  length      = 12
  min_upper   = 2
  min_numeric = 2
  special     = false
}

resource "aws_ssm_parameter" "dashboard_admin_username" {
  name  = "${local.ssm_ses_dashboard_prefix}/ADMIN_NAME"
  value = local.dashboard_admin_name
  type  = "String"
}

resource "aws_ssm_parameter" "dashboard_admin_email" {
  name  = "${local.ssm_ses_dashboard_prefix}/ADMIN_EMAIL"
  value = local.dashboard_admin_email
  type  = "String"
}

resource "aws_ssm_parameter" "dashboard_admin_password" {
  name  = "${local.ssm_ses_dashboard_prefix}/ADMIN_PASSWORD"
  value = random_password.dashboard_user_password.result
  type  = "SecureString"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
