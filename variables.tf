###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type        = string
  description = "Client name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "application" {
  type = string
  description = "Application name"
}

#####################################
####### Dynamodb variables ##########
#####################################
variable "dynamo_config" {
  type = list(object({
    billing_mode   = string
    read_capacity  = number
    write_capacity = number
    hash_key       = string
    range_key      = string
    point_in_time_recovery = string
    deletion_protection_enabled = bool
    attributes = list(object({
        name = string
        type = string
    }))
    server_side_encryption = list(object({
      enabled = string
      kms_key_arn = string
    }))
    replicas = list(object({
      kms_key_arn = string
      point_in_time_recovery = string
      propagate_tags = string
      region_name = string
    }))
    functionality = string
  }))
}

