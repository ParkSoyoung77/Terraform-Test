variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = "std17-s3-role"
}

variable "role_description" {
  description = "IAM role description"
  type        = string
  default     = "Allow Ec2 Instance to call AWS services on your behalf"
}

variable "policy_arn" {
  description = "Managed policy ARN to attach to the role"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

variable "tags" {
  description = "Tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}