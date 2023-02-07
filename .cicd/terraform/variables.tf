variable "environment" {
  type = string
}

variable "namespace" {
  type = string
}

variable "app_name" {
  type = string
  default = "ses-dashboard"
  description = "Application name, as shown in DD."
}

variable "app_version" {
  type = string
  description = "An unique identifier the the application and docker image. It will be appended to the images, as a tag. E.g.: acbde-local. This value is also supplied to DD as the version."
}

variable "aws_account_id" {
  type = string
  description = "Account ID where resources will be created."
}

variable "region" {
  type = string
  description = "Region where resources will be created."
}
