variable "az_1" {
  description = "Availability Zone 1"
  type        = string
}

variable "az_2" {
  description = "Availability Zone 2"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "web_AZ-1" {
  description = "The CIDR block for the web Availability Zone 1"
  type        = string
}

variable "web_AZ-2" {
  description = "The CIDR block for the web Availability Zone 2"
  type        = string
}

variable "app_AZ-1" {
  description = "The CIDR block for the app Availability Zone 1"
  type        = string
}

variable "app_AZ-2" {
  description = "The CIDR block for the app Availability Zone 2"
  type        = string
}

variable "db_AZ-1" {
  description = "The CIDR block for the db Availability Zone 1"
  type        = string
}

variable "db_AZ-2" {
  description = "The CIDR block for the db Availability Zone 2"
  type        = string
}