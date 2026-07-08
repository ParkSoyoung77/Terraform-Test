provider "aws" {
    # 리전: 싱가포르
    region = "ap-southeast-1"

    default_tags {
        tags = {
            Owner = "std17"
            ManageBy = "Terraform"
        }
    }
}