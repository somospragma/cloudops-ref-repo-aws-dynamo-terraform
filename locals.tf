# locals.tf
# Valores locales y transformaciones de datos
# Cumple con PC-IAC-003 (nomenclatura), PC-IAC-009 (transformaciones), PC-IAC-012 (estructuras)

locals {
  # Prefijo de gobernanza para nomenclatura estándar (PC-IAC-003)
  # Formato: {client}-{project}-{environment}
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Construcción de nombres de tablas DynamoDB (PC-IAC-003)
  # Formato: {governance_prefix}-ddb-{application}-{table_key}
  table_names = {
    for key, config in var.dynamo_config :
    key => "${local.governance_prefix}-ddb-${var.application}-${key}"
  }

  # Mapa plano de Lambda triggers para for_each (PC-IAC-010)
  # Genera claves tipo "table_key-index" para cada trigger
  lambda_trigger_map = merge([
    for table_key, config in var.dynamo_config : {
      for idx, trigger in config.lambda_triggers :
      "${table_key}-${idx}" => {
        table_key = table_key
        trigger   = trigger
      }
    }
  ]...)

  # Mapa plano de GSI Auto Scaling para for_each
  # Genera claves tipo "table_key-gsi_name" para read y write
  gsi_autoscaling_read_map = merge([
    for table_key, config in var.dynamo_config : {
      for gsi in config.global_secondary_indexes :
      "${table_key}-${gsi.name}" => {
        table_key = table_key
        gsi_name  = gsi.name
        config    = gsi.autoscaling_read
      }
      if config.autoscaling_enabled && gsi.autoscaling_read != null
    }
  ]...)

  gsi_autoscaling_write_map = merge([
    for table_key, config in var.dynamo_config : {
      for gsi in config.global_secondary_indexes :
      "${table_key}-${gsi.name}" => {
        table_key = table_key
        gsi_name  = gsi.name
        config    = gsi.autoscaling_write
      }
      if config.autoscaling_enabled && gsi.autoscaling_write != null
    }
  ]...)
}
