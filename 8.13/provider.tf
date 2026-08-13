provider "aws" {
    # 리전: 오사카(AZ 3개)
    region = var.aws_region

    default_tags {
        tags = {
            Owner    = "std17"
            Class    = "bipa17"
            ManageBy = "Terraform"
        }
    }
}