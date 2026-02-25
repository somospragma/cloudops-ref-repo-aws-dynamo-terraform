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

  # Transformación de configuración con valores por defecto seguros (PC-IAC-009)
  dynamo_config_with_defaults = {
    for key, config in var.dynamo_config : key => merge(config, {
      # Valores por defecto de seguridad (PC-IAC-020)
      deletion_protection_enabled = try(config.deletion_protection_enabled, true)
      point_in_time_recovery      = try(config.point_in_time_recovery, true)

      # Asegurar tipos correctos
      replicas        = try(config.replicas, [])
      additional_tags = try(config.additional_tags, {})
    })
  }

  # Validación de consistencia de atributos
  attribute_names = {
    for key, config in var.dynamo_config : key => [
      for attr in config.attributes : attr.name
    ]
  }

  # Verificar que hash_key y range_key estén en attributes
  valid_keys = {
    for key, config in var.dynamo_config : key => (
      contains(local.attribute_names[key], config.hash_key) &&
      try(config.range_key == null || contains(local.attribute_names[key], config.range_key), true)
    )
  }
}
