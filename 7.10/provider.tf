provider "aws" {
    # 리전: 캘리포니아(AZ 2개)
    region = "us-west-1"

    default_tags {
        tags = {
            Owner = "std17"
            Class = "bipa17"
            ManageBy = "Terraform"
        }
    }
}