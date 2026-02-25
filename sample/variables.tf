# sample/variables.tf
# Variables del ejemplo
# Cumple con PC-IAC-002 (Variables con validaciones)

###########################################
########## Common variables ###############
###########################################

variable "client" {
  description = "Client name for resource naming"
  type        = string

  validation {
    condition     = length(var.client) > 0
    error_message = "Client name cannot be empty."
  }
}

variable "environment" {
  description = "Environment where resources will be deployed"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, stg, pdn."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "project" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = length(var.project) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "application" {
  description = "Application name for resource naming"
  type        = string

  validation {
    condition     = length(var.application) > 0
    error_message = "Application name cannot be empty."
  }
}

###########################################
########## DynamoDB variables #############
###########################################

variable "dynamo_config" {
  description = "Map of DynamoDB table configurations for the example"
  type = map(object({
    billing_mode                = string
    read_capacity               = optional(number)
    write_capacity              = optional(number)
    hash_key                    = string
    range_key                   = optional(string)
    point_in_time_recovery      = optional(bool, true)
    deletion_protection_enabled = optional(bool, true)
    kms_key_arn                 = optional(string, "")

    attributes = list(object({
      name = string
      type = string
    }))

    server_side_encryption = object({
      enabled     = bool
      kms_key_arn = optional(string, "")
    })

    replicas = optional(list(object({
      kms_key_arn            = optional(string)
      point_in_time_recovery = optional(bool)
      propagate_tags         = optional(bool)
      region_name            = string
    })), [])

    stream_enabled   = optional(bool, false)
    stream_view_type = optional(string, "NEW_AND_OLD_IMAGES")

    ttl_enabled        = optional(bool, false)
    ttl_attribute_name = optional(string, "")

    global_secondary_indexes = optional(list(object({
      name = string
      key_schema = list(object({
        attribute_name = string
        key_type       = string # "HASH" or "RANGE"
      }))
      projection_type    = string
      non_key_attributes = optional(list(string), [])
      read_capacity      = optional(number)
      write_capacity     = optional(number)
    })), [])

    local_secondary_indexes = optional(list(object({
      name               = string
      range_key          = string
      projection_type    = string
      non_key_attributes = optional(list(string), [])
    })), [])

    autoscaling_enabled = optional(bool, false)
    autoscaling_read = optional(object({
      min_capacity       = number
      max_capacity       = number
      target_utilization = optional(number, 70)
      scale_in_cooldown  = optional(number, 60)
      scale_out_cooldown = optional(number, 60)
    }))
    autoscaling_write = optional(object({
      min_capacity       = number
      max_capacity       = number
      target_utilization = optional(number, 70)
      scale_in_cooldown  = optional(number, 60)
      scale_out_cooldown = optional(number, 60)
    }))

    functionality = string
  }))
}





