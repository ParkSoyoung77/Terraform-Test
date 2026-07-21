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