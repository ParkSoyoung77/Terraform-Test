data "aws_availability_zones" "az" {
    state = "available"
}

data "aws_route53_zone" "std17_zone" {
    name = var.root_domain
}