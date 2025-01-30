module "dynamo" {
  source        = "./module/dynamo"
  client        = var.client
  functionality = var.functionality
  environment   = var.environment

  dynamo_config = [
    {
      billing_mode   = var.billing_mode
      read_capacity  = var.read_capacity
      write_capacity = var.write_capacity
      hash_key       = var.hash_key
      range_key      = var.range_key
      point_in_time_recovery = var.point_in_time_recovery
      deletion_protection_enabled = var.deletion_protection_enabled

      attributes = [
        {
          name = var.hash_key
          type = "S"
        },
        {
          name = var.range_key
          type = "N"
        }
      ]

      server_side_encryption = [
        {
          enabled     = var.server_side_encryption_enable
          kms_key_arn = var.server_side_encryption_kms #maneja la administrada por AWS
        }
      ]

      replicas = [
        # {
        #   kms_key_arn            = var.replicas_kms #maneja la administrada por AWS
        #   point_in_time_recovery = var.point_in_time_recovery
        #   propagate_tags         = var.propagate_tags
        #   region_name            = var.region_name
        # }
      ]
      application = var.project
    }
  ]
}