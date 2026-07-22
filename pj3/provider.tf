provider "aws" {
    # 리전: 캘리포니아(AZ 2개)
    region = var.aws_region

    default_tags {
        tags = {
            Owner    = "std17"
            Class    = "bipa17"
            ManageBy = "Terraform"
        }
    }
}

# CloudFront 커스텀 도메인 인증서는 반드시 us-east-1에 있어야 함
provider "aws" {
    alias  = "us_east_1"
    region = "us-east-1"
}