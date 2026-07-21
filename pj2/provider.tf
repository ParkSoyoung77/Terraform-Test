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

# CloudFront에 붙일 ACM 인증서는 반드시 us-east-1 리전이어야 함
provider "aws" {
    alias  = "us_east_1"
    region = "us-east-1"

    default_tags {
        tags = {
            Owner    = "std17"
            Class    = "bipa17"
            ManageBy = "Terraform"
        }
    }
}