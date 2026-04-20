###########################################
########## Common variables ###############
###########################################

variable "environment" {
  description = "Environment where resources will be deployed"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "pdn", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, stg, pdn, prod."
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

    # DynamoDB Streams configuration
    stream_enabled   = optional(bool, false)
    stream_view_type = optional(string, "NEW_AND_OLD_IMAGES")

    # Time To Live (TTL) configuration
    ttl_enabled        = optional(bool, false)
    ttl_attribute_name = optional(string, "")

    # Global Secondary Indexes (GSI)
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

      # Auto Scaling para GSI (solo para PROVISIONED)
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
    })), [])

    # Local Secondary Indexes (LSI)
    local_secondary_indexes = optional(list(object({
      name               = string
      range_key          = string
      projection_type    = string
      non_key_attributes = optional(list(string), [])
    })), [])

    # Auto Scaling configuration (solo para PROVISIONED)
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

    # Lambda Triggers (DynamoDB Streams → Lambda)
    lambda_triggers = optional(list(object({
      function_name                      = string                    # ARN o nombre de la función Lambda
      starting_position                  = optional(string, "LATEST") # LATEST | TRIM_HORIZON
      enabled                            = optional(bool, true)
      batch_size                         = optional(number, 100)      # 1-10000
      maximum_batching_window_in_seconds = optional(number, 0)        # 0-300
      parallelization_factor             = optional(number, 1)        # 1-10
      maximum_record_age_in_seconds      = optional(number, -1)       # -1 o 60-604800
      maximum_retry_attempts             = optional(number, -1)       # -1 o 0-10000
      bisect_batch_on_function_error     = optional(bool, false)
      tumbling_window_in_seconds         = optional(number, 0)        # 0-900
      function_response_types            = optional(list(string), []) # ["ReportBatchItemFailures"]
      destination_on_failure_arn         = optional(string, "")       # ARN de SQS/SNS para DLQ
      filter_pattern                     = optional(string, "")       # Patrón de filtrado de eventos
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
      v.billing_mode != "PROVISIONED" || try(
        v.read_capacity != null && v.read_capacity > 0 &&
        v.write_capacity != null && v.write_capacity > 0,
        false
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
      try(v.range_key == null || contains([for attr in v.attributes : attr.name], v.range_key), true)
    ])
    error_message = "range_key must be defined in the attributes list when specified."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      !v.stream_enabled || contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], v.stream_view_type)
    ])
    error_message = "stream_view_type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES when stream is enabled."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      !v.ttl_enabled || (v.ttl_enabled && v.ttl_attribute_name != "")
    ])
    error_message = "ttl_attribute_name must be specified when ttl_enabled is true."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes :
        contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
      ]
    ]))
    error_message = "GSI projection_type must be one of: ALL, KEYS_ONLY, INCLUDE."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes :
        gsi.projection_type != "INCLUDE" || length(gsi.non_key_attributes) > 0
      ]
    ]))
    error_message = "GSI with projection_type INCLUDE must specify non_key_attributes."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes : [
          for ks in gsi.key_schema :
          contains([for attr in v.attributes : attr.name], ks.attribute_name)
        ]
      ]
    ]))
    error_message = "All GSI key_schema attributes must be defined in the attributes list."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes : [
          for ks in gsi.key_schema :
          contains(["HASH", "RANGE"], ks.key_type)
        ]
      ]
    ]))
    error_message = "GSI key_schema key_type must be either 'HASH' or 'RANGE'."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes :
        length(gsi.key_schema) > 0 && length(gsi.key_schema) <= 2
      ]
    ]))
    error_message = "GSI key_schema must have 1 (HASH) or 2 (HASH + RANGE) key definitions."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes :
        length([for ks in gsi.key_schema : ks if ks.key_type == "HASH"]) == 1
      ]
    ]))
    error_message = "Each GSI key_schema must have exactly one HASH key."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for gsi in v.global_secondary_indexes :
        v.billing_mode != "PROVISIONED" || try(
          gsi.read_capacity != null && gsi.read_capacity > 0 &&
          gsi.write_capacity != null && gsi.write_capacity > 0,
          false
        )
      ]
    ]))
    error_message = "GSI read_capacity and write_capacity must be specified and > 0 when table billing_mode is PROVISIONED."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for lsi in v.local_secondary_indexes :
        contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type)
      ]
    ]))
    error_message = "LSI projection_type must be one of: ALL, KEYS_ONLY, INCLUDE."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for lsi in v.local_secondary_indexes :
        lsi.projection_type != "INCLUDE" || length(lsi.non_key_attributes) > 0
      ]
    ]))
    error_message = "LSI with projection_type INCLUDE must specify non_key_attributes."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for lsi in v.local_secondary_indexes :
        contains([for attr in v.attributes : attr.name], lsi.range_key)
      ]
    ]))
    error_message = "LSI range_key must be defined in the attributes list."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      length(v.local_secondary_indexes) == 0 || v.range_key != null
    ])
    error_message = "Local Secondary Indexes require the table to have a range_key (sort key)."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      !v.autoscaling_enabled || v.billing_mode == "PROVISIONED"
    ])
    error_message = "Auto Scaling can only be enabled for tables with billing_mode = PROVISIONED."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      !v.autoscaling_enabled || (v.autoscaling_read != null || v.autoscaling_write != null)
    ])
    error_message = "When autoscaling_enabled is true, at least one of autoscaling_read or autoscaling_write must be configured."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      try(v.autoscaling_read == null || (v.autoscaling_read.min_capacity > 0 && v.autoscaling_read.max_capacity > 0 && v.autoscaling_read.max_capacity >= v.autoscaling_read.min_capacity), true)
    ])
    error_message = "Auto Scaling read: min_capacity and max_capacity must be > 0, and max_capacity >= min_capacity."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      try(v.autoscaling_write == null || (v.autoscaling_write.min_capacity > 0 && v.autoscaling_write.max_capacity > 0 && v.autoscaling_write.max_capacity >= v.autoscaling_write.min_capacity), true)
    ])
    error_message = "Auto Scaling write: min_capacity and max_capacity must be > 0, and max_capacity >= min_capacity."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      try(v.autoscaling_read == null || (v.autoscaling_read.target_utilization > 0 && v.autoscaling_read.target_utilization <= 100), true)
    ])
    error_message = "Auto Scaling read target_utilization must be between 1 and 100."
  }

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      try(v.autoscaling_write == null || (v.autoscaling_write.target_utilization > 0 && v.autoscaling_write.target_utilization <= 100), true)
    ])
    error_message = "Auto Scaling write target_utilization must be between 1 and 100."
  }

  # ── Lambda Triggers validations ──

  validation {
    condition = alltrue([
      for k, v in var.dynamo_config :
      length(v.lambda_triggers) == 0 || v.stream_enabled
    ])
    error_message = "stream_enabled must be true when lambda_triggers are configured."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        contains(["LATEST", "TRIM_HORIZON"], trigger.starting_position)
      ]
    ]))
    error_message = "Lambda trigger starting_position must be either 'LATEST' or 'TRIM_HORIZON'."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        trigger.batch_size >= 1 && trigger.batch_size <= 10000
      ]
    ]))
    error_message = "Lambda trigger batch_size must be between 1 and 10000."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        trigger.parallelization_factor >= 1 && trigger.parallelization_factor <= 10
      ]
    ]))
    error_message = "Lambda trigger parallelization_factor must be between 1 and 10."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        trigger.maximum_batching_window_in_seconds >= 0 && trigger.maximum_batching_window_in_seconds <= 300
      ]
    ]))
    error_message = "Lambda trigger maximum_batching_window_in_seconds must be between 0 and 300."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        trigger.tumbling_window_in_seconds >= 0 && trigger.tumbling_window_in_seconds <= 900
      ]
    ]))
    error_message = "Lambda trigger tumbling_window_in_seconds must be between 0 and 900."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        length(trigger.function_response_types) == 0 || alltrue([
          for frt in trigger.function_response_types :
          contains(["ReportBatchItemFailures"], frt)
        ])
      ]
    ]))
    error_message = "Lambda trigger function_response_types only supports 'ReportBatchItemFailures'."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        trigger.maximum_record_age_in_seconds == -1 || (trigger.maximum_record_age_in_seconds >= 60 && trigger.maximum_record_age_in_seconds <= 604800)
      ]
    ]))
    error_message = "Lambda trigger maximum_record_age_in_seconds must be -1 (forever) or between 60 and 604800."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.dynamo_config : [
        for trigger in v.lambda_triggers :
        trigger.maximum_retry_attempts == -1 || (trigger.maximum_retry_attempts >= 0 && trigger.maximum_retry_attempts <= 10000)
      ]
    ]))
    error_message = "Lambda trigger maximum_retry_attempts must be -1 (forever) or between 0 and 10000."
  }
}
