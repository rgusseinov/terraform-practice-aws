variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  description = "Instance type"
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID"
  default = "ami-08b5b3a93ed654d19" # Amazon Linux 2023 AMI
}