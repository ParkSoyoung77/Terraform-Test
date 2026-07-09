provider "aws" {
    # 리전: 오하이오
    region = "us-east-2"

    default_tags {
        tags = {
            Owner = "std17"
            Class = "bipa17"
            ManageBy = "Terraform"
        }
    }
}