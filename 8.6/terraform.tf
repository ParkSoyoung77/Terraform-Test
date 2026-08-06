terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~>6.0"
        }
        time = {
            source  = "hashicorp/time"
            version = "~> 0.11"
        }
        random = { 
            source = "hashicorp/random" 
        }
        archive = {
            source  = "hashicorp/archive"
            version = "~> 2.4"
        }
    }
    cloud {
        organization = "terraform_code_test"
        workspaces {
            name = "terraform-test"
        }
    }
}