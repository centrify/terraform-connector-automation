provider "aws" {
  region                  = var.aws_region  
}

variable "aws_region" {
  description = "Name of the AWS region to operate in"
  default     = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block to use for internal VPC addresses"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet_cidrs" {
  description = "List of CIDR for public subnets (must fall within vpc_cidr_block)"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "vpc_private_subnet_cidrs" {
  description = "List of CIDR for public subnets (must fall within vpc_cidr_block)"
  default     = ["10.0.50.0/24", "10.0.51.0/24"]
}

variable "connector_disk_size" {
  description = "Volume Size for Connector Machine EBS volume (default = 100)"
  default     = "100"
}

variable "connector_instance_type" {
  description = "Instance type for Connector host"

  // Size connectors appropriately for the expected workload, t2.medium is default
  default = "t2.medium"
}

variable "reg_user" {
  description = "The user identity to use to register the connector"
}

variable "reg_pass" {
  description = "Password for the registering user"
}

variable "reg_url" {
  description = "Tenant URL to register Connector with"
}

variable "conn_url" {
  description = "Cloud-Management-Suite-win64.zip Download URL"
  default     = "https://edge.centrify.com/products/cloud-service/ProxyDownload/Cloud-Management-Suite-win64.zip"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_subnets  = aws_subnet.cfy_public_subnets.*.id
  private_subnets = aws_subnet.cfy_private_subnets.*.id
}

resource "random_id" "instance" {
  byte_length = 8
}

