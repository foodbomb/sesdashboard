locals {
  desired_count      = var.environment == "production" ? 1 : 1
  container_name     = var.app_name
  container_port     = 80
  container_image    = "${data.aws_ecr_repository.ses_dashboard.repository_url}:${var.app_version}"
  container_version  = var.app_version
  cluster_name       = data.aws_ecs_cluster.main.cluster_name
  memory_reservation = 256
  dd_service         = var.app_name
  all_secrets        = [
    aws_ssm_parameter.db_host,
    aws_ssm_parameter.db_port,
    aws_ssm_parameter.db_name,
    aws_ssm_parameter.db_user,
    aws_ssm_parameter.db_password,
    data.aws_ssm_parameter.mailer_access_key_id,
    data.aws_ssm_parameter.mailer_access_key_secret,
    aws_ssm_parameter.dashboard_admin_password
  ]
  environment_variables = [
    for user_detail in [
      aws_ssm_parameter.dashboard_admin_email,
      aws_ssm_parameter.dashboard_admin_username,
      data.aws_ssm_parameter.mailer_region,
      data.aws_ssm_parameter.mailer_default_configuration_set,
    ]: {
      value = user_detail.value
      name  = upper(reverse(split("/", user_detail.name, ))[0])
    }
  ]

  environment_secrets = [
    for param in local.all_secrets : {
      valueFrom = param.name,
      name      = upper(reverse(split("/", param.name, ))[0])
    }
  ]

  migration_override_template = {
    containerOverrides = [
      {
        name    = local.container_name
        command = ["/bin/bash", "-c", "make init_within_container"]
      }
    ]
  }

}

data "aws_ecs_task_definition" "latest" {
  task_definition = aws_ecs_task_definition.api.family
}

resource "aws_ecs_task_definition" "api" {
  family = local.default_prefix

  task_role_arn      = "arn:aws:iam::238087339149:role/opencartService"
  execution_role_arn = "arn:aws:iam::238087339149:role/opencartService"

  container_definitions = jsonencode([
    {
      name    = local.container_name
      image   = local.container_image,
      command = [
        "/bin/bash",
        "-c",
        "export DD_AGENT_HOST=$(curl http://169.254.169.254/latest/meta-data/local-ipv4); make init_within_container && apache2-foreground"
      ],
      memoryReservation = local.memory_reservation,
      cpu               = 0,
      portMappings      = [
        {
          hostPort      = 0,
          containerPort = local.container_port,
          protocol      = "tcp"
        }
      ],
      essential   = true,
      environment = concat(local.environment_variables, [
        {
          name  = "DD_SERVICE",
          value = local.container_name
        },
        {
          name  = "APP_ENV",
          value = var.environment
        },
        {
          name  = "APP_DEBUG",
          value = "0"
        },
        {
          name  = "DD_TRACE_ANALYTICS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_CURL_ANALYTICS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_ELOQUENT_ANALYTICS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_GUZZLE_ANALYTICS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_LARAVEL_ANALYTICS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_LUMEN_ANALYTICS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_TRACE_PDO_ANALYTICS_ENABLED"
          value = "true"
        },
      ])
      secrets      = local.environment_secrets
      dockerLabels = {
        "com.datadoghq.tags.env"     = var.environment
        "com.datadoghq.tags.version" = var.app_version
        "com.datadoghq.ad.logs"      = jsonencode([
          {
            source  = "apache"
            service = var.app_name
          }
        ])
      },
    },
  ])
}

resource "aws_lb_target_group" "this" {
  name     = "${local.default_prefix}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path                = "/login"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = "30"
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = data.aws_lb_listener.listener_443.arn

  condition {
    host_header {
      values = [
        aws_route53_record.ses_dashboard.name
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_ecs_service" "this" {
  #  depends_on              = [module.db-migration]
  name                    = local.default_prefix
  cluster                 = data.aws_ecs_cluster.main.cluster_name
  task_definition         = aws_ecs_task_definition.api.arn
  scheduling_strategy     = "REPLICA"
  enable_ecs_managed_tags = true

  deployment_minimum_healthy_percent = 100

  desired_count                     = local.desired_count
  health_check_grace_period_seconds = 0

  load_balancer {
    container_name   = local.container_name
    container_port   = 80
    target_group_arn = aws_lb_target_group.this.arn
  }

  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }

  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

  deployment_controller {
    type = "ECS"
  }
}
