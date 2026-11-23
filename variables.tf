variable "aws_region" {
  description = "AWS region used for the Linux Infrastructure Lab"
  type        = string
  default     = "eu-west-2"
}

variable "allowed_ssh_cidr" {
  description = "Trusted CIDR block permitted to access SSH"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key used by the Linux Lab"
  type        = string
}