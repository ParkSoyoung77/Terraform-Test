variable "aws_region" {
    type = string
}

variable "account_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "target_group_arn" {
    type = string
}

variable "execution_role_arn" {
    type = string
}

variable "execution_role_name" {
    type = string
}

variable "mysql_credentials_secret_arn" {
    type = string
}

variable "general_desired_count" {
    type = number
}