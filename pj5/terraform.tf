terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~>6.0"
        }
        random = { 
            source = "hashicorp/random" 
        }
    }
    cloud {
        organization = "terraform_code_test"
        workspaces {
            name = "terraform-test"
        }
    }
}