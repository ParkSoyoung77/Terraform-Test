variable "vpc_id" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "ecs_general_sg_id" {
    type = string
}

variable "ecs_db_sg_id" {
    type = string
}

variable "ecs_instance_profile" {
    type = string
}

variable "ecs_ami_id" {
    type = string
}

variable "general_instance_type" {
    type = string
}

variable "db_instance_type" {
    type = string
}

variable "general_desired_count" {
    type = number
}