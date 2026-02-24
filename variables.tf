###########################################
########## Common variables ###############
###########################################

variable "environment" {
  description = "Environment where resources will be deployed"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, stg, pdn."
  }
}

variable "client" {
  description = "Client name for resource naming"
  type        = string

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "Client name must be between 1 and 10 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "Client name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "Project name must be between 1 and 15 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "application" {
  description = "Application name for resource naming"
  type        = string

  validation {
    condition     = length(var.application) > 0 && length(var.application) <= 20
    error_message = "Application name must be between 1 and 20 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.application))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens."
  }
}

#####################################
####### Dynamodb variables ##########
#####################################
variable "dynamo_config" {
  description = "Map of DynamoDB table configurations. Key is the table identifier used in naming."
  type = map(object({
    billing_mode                = string
    read_capacity               = optional(number)
    write_capacity              = optional(number)
    hash_key                    = string
    range_key                   = optional(string)
    point_in_time_recovery      = optional(bool, true)
    deletion_protection_enabled = optional(bool, true)

    attributes = list(object({
      name = string
      type = string
    }))

    server_side_encryption = object({
      enabled     = bool
      kms_key_arn = optional(string)
    })

    replicas = optional(list(object({
      kms_key_arn            = optional(string)
      point_in_time_recovery = optional(bool)
      propagate_tags         = optional(bool)
      region_name            = string
    })), [])

    functionality   = string
    additional_tags = optional(map(string), {})
  }))

  validation {
    condition     = length(var.dynamo_config) > 0
    error_message = "At least one DynamoDB table configuration is required."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      v.server_side_encryption.enabled == true
    ])
    error_message = "Server-side encryption must be enabled for all tables (PC-IAC-020)."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      contains(["PAY_PER_REQUEST", "PROVISIONED"], v.billing_mode)
    ])
    error_message = "billing_mode must be either 'PAY_PER_REQUEST' or 'PROVISIONED'."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      v.billing_mode != "PROVISIONED" || (
        v.read_capacity != null && v.write_capacity != null &&
        v.read_capacity > 0 && v.write_capacity > 0
      )
    ])
    error_message = "read_capacity and write_capacity must be specified and > 0 when billing_mode is PROVISIONED."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for attr in v.attributes :
        contains(["S", "N", "B"], attr.type)
      ]
    ]))
    error_message = "Attribute type must be one of: S (string), N (number), B (binary)."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      contains([for attr in v.attributes : attr.name], v.hash_key)
    ])
    error_message = "hash_key must be defined in the attributes list."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      v.range_key == null || contains([for attr in v.attributes : attr.name], v.range_key)
    ])
    error_message = "range_key must be defined in the attributes list when specified."
  }
}

