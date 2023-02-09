locals {
  ssm_metabase_prefix  = "${local.ssm_default_prefix}/metabase"
  metabase_db_username = lower(replace(var.app_name, "-", "_"))
  ses_db_name          = lower(replace(var.app_name, "-", "_"))
  ses_db_username      = local.ses_db_name
}

data "aws_ssm_parameter" "metabase_db_host" {
  name = "${local.ssm_metabase_prefix}/db-host"
}

data "aws_ssm_parameter" "metabase_db_port" {
  name = "${local.ssm_metabase_prefix}/db-port"
}

data "aws_ssm_parameter" "metabase_db_user" {
  name = "${local.ssm_metabase_prefix}/db-user"
}

data "aws_ssm_parameter" "metabase_db_pass" {
  name = "${local.ssm_metabase_prefix}/db-pass"
}

provider "mysql" {
  endpoint = join(":", [
    data.aws_ssm_parameter.metabase_db_host.value,
    data.aws_ssm_parameter.metabase_db_port.value
  ])
  username = data.aws_ssm_parameter.metabase_db_user.value
  password = data.aws_ssm_parameter.metabase_db_pass.value
  tls      = "skip-verify"
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}

# Save database info to SSM
resource "aws_ssm_parameter" "db_host" {
  name  = "${local.ssm_ses_dashboard_prefix}/MYSQL_HOST"
  value = data.aws_ssm_parameter.metabase_db_host.value
  type  = "String"
}

resource "aws_ssm_parameter" "db_port" {
  name  = "${local.ssm_ses_dashboard_prefix}/MYSQL_PORT"
  value = data.aws_ssm_parameter.metabase_db_port.value
  type  = "String"
}

resource "aws_ssm_parameter" "db_name" {
  name  = "${local.ssm_ses_dashboard_prefix}/MYSQL_DATABASE"
  value = local.ses_db_name
  type  = "String"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm_ses_dashboard_prefix}/MYSQL_PASSWORD"
  value = random_password.db_password.result
  type  = "SecureString"
}

resource "aws_ssm_parameter" "db_user" {
  name  = "${local.ssm_ses_dashboard_prefix}/MYSQL_USER"
  value = local.ses_db_username
  type  = "String"
}

resource "mysql_database" "schema" {
  name                  = aws_ssm_parameter.db_name.value
  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_0900_ai_ci"
}

resource "mysql_user" "app_user" {
  depends_on = [
    aws_ssm_parameter.db_password,
    aws_ssm_parameter.db_name
  ]

  host               = "%"
  user               = aws_ssm_parameter.db_user.value
  plaintext_password = aws_ssm_parameter.db_password.value

  lifecycle {
    ignore_changes = [
      #      plaintext_password
    ]
  }
}

resource "mysql_grant" "attach_write_privileges" {
  depends_on = [
    mysql_database.schema,
    mysql_user.app_user
  ]
  database = aws_ssm_parameter.db_name.value
  user     = aws_ssm_parameter.db_user.value
  host     = "%"
  table    = "*"
  grant    = true
  privileges = [
    "ALL"
  ]
}
