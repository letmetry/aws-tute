variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The target AWS region to deploy the VPC infrastructure."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The root CIDR block for the Virtual Private Cloud."
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Environment boundary tagging used across all deployed components."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR spacing blocks for internet-facing edge subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  description = "CIDR spacing blocks for isolated application-tier subnets."
}
