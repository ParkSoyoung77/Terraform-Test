data "aws_availability_zones" "az" {
    state = "available"
}

data "aws_acm_certificate" "std17_cert" {
    domain      = "www.sy99.cloud"
    statuses    = ["ISSUED"]
    most_recent = true
}

data "aws_route53_zone" "std17_zone" {
    name         = "sy99.cloud"
    private_zone = false
}