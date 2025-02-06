###########################################
########## Common variables ###############
###########################################

variable "client" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "profile" {
  type = string
}
variable "common_tags" {
    type = map(string)
    description = "Tags comunes aplicadas a los recursos"
}
variable "project" {
  type = string  
}

variable "application" {
  type = string  
  description = "Application name"
}






########### Varibales Secret Manager
variable "billing_mode" {
  type    = string
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "El valor de 'billing_mode' debe ser 'PAY_PER_REQUEST' o 'PROVISIONED'."
  }
}
variable "read_capacity" {
  type    = number
  default = null  
}
variable "write_capacity" {
  type    = number
  default = null  
}
variable "hash_key" {
  type = string  
}
variable "range_key" {
  type = string  
}
variable "point_in_time_recovery" {
  type = string  
}
variable "deletion_protection_enabled" {
  type    = bool
  default = true  
}
variable "server_side_encryption_enable" {
  type = string  
}
variable "server_side_encryption_kms" {
  type    = string
  default = null  
}
variable "replicas_kms" {
  type    = string
  default = null  
}
variable "propagate_tags" {
  type    = string
}
variable "region_name" {
  type    = string
}

variable "functionality" {
  type = string  
}




