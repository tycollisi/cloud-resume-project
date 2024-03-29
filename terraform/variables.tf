variable "aws_region" {
  description = "AWS Region Target"
  default     = "us-east-1"
}

variable "cli_profile" {
  description = "Deployment Credentials / Run Environment"
  default     = "tcollisi"
}

variable "environment" {
  description = "Environment"
  default     = "prod"
}
