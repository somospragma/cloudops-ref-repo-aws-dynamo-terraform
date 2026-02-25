# main.tf
# Recursos principales del módulo DynamoDB
# Cumple con PC-IAC-010 (for_each), PC-IAC-020 (seguridad)

resource "aws_dynamodb_table" "dynamo_table" {
  provider = aws.project       # PC-IAC-005: Uso de alias inyectado
  for_each = var.dynamo_config # PC-IAC-010: for_each para estabilidad

  # Nomenclatura construida en locals.tf (PC-IAC-003)
  name = local.table_names[each.key]

  # Configuración de capacidad
  billing_mode   = each.value.billing_mode
  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity

  # Claves primarias
  hash_key  = each.value.hash_key
  range_key = each.value.range_key

  # Protección contra eliminación (PC-IAC-020)
  deletion_protection_enabled = each.value.deletion_protection_enabled

  # Definición de atributos (PC-IAC-014: bloques dinámicos)
  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Cifrado en reposo obligatorio (PC-IAC-020)
  dynamic "server_side_encryption" {
    for_each = [each.value.server_side_encryption]
    content {
      enabled     = server_side_encryption.value.enabled
      kms_key_arn = server_side_encryption.value.kms_key_arn
    }
  }

  # Réplicas para alta disponibilidad
  dynamic "replica" {
    for_each = each.value.replicas
    content {
      kms_key_arn            = replica.value.kms_key_arn
      point_in_time_recovery = replica.value.point_in_time_recovery
      propagate_tags         = replica.value.propagate_tags
      region_name            = replica.value.region_name
    }
  }

  # Point-in-time recovery para recuperación de datos
  point_in_time_recovery {
    enabled = each.value.point_in_time_recovery
  }

  # DynamoDB Streams configuration (opcional)
  stream_enabled   = each.value.stream_enabled
  stream_view_type = each.value.stream_enabled ? each.value.stream_view_type : null

  # Time To Live (TTL) configuration
  dynamic "ttl" {
    for_each = each.value.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = each.value.ttl_attribute_name
    }
  }

  # Global Secondary Indexes (GSI)
  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_indexes
    content {
      name = global_secondary_index.value.name

      # Key schema (nuevo patrón recomendado)
      dynamic "key_schema" {
        for_each = global_secondary_index.value.key_schema
        content {
          attribute_name = key_schema.value.attribute_name
          key_type       = key_schema.value.key_type
        }
      }

      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  # Local Secondary Indexes (LSI)
  dynamic "local_secondary_index" {
    for_each = each.value.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  # Etiquetas (PC-IAC-004)
  tags = merge(
    {
      Name          = local.table_names[each.key]
      Functionality = each.value.functionality
      BillingMode   = each.value.billing_mode
      ManagedBy     = "terraform"
      Module        = "dynamodb-module"
    },
    try(each.value.additional_tags, {})
  )

  # Protección contra destrucción accidental (PC-IAC-020)
  # Nota: prevent_destroy debe ser un valor literal, no puede ser dinámico
  # Para deshabilitar, comentar este bloque manualmente
  # lifecycle {
  #   prevent_destroy = true
  # }
}


############################################################################
# Auto Scaling Configuration (solo para PROVISIONED)
############################################################################

# Auto Scaling Target - Read Capacity
resource "aws_appautoscaling_target" "dynamodb_table_read" {
  provider = aws.project
  for_each = {
    for k, v in var.dynamo_config :
    k => v
    if v.autoscaling_enabled && v.autoscaling_read != null
  }

  max_capacity       = each.value.autoscaling_read.max_capacity
  min_capacity       = each.value.autoscaling_read.min_capacity
  resource_id        = "table/${aws_dynamodb_table.dynamo_table[each.key].name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy - Read Capacity
resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  provider = aws.project
  for_each = {
    for k, v in var.dynamo_config :
    k => v
    if v.autoscaling_enabled && v.autoscaling_read != null
  }

  name               = "${local.table_names[each.key]}-read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = each.value.autoscaling_read.target_utilization
    scale_in_cooldown  = each.value.autoscaling_read.scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling_read.scale_out_cooldown
  }
}

# Auto Scaling Target - Write Capacity
resource "aws_appautoscaling_target" "dynamodb_table_write" {
  provider = aws.project
  for_each = {
    for k, v in var.dynamo_config :
    k => v
    if v.autoscaling_enabled && v.autoscaling_write != null
  }

  max_capacity       = each.value.autoscaling_write.max_capacity
  min_capacity       = each.value.autoscaling_write.min_capacity
  resource_id        = "table/${aws_dynamodb_table.dynamo_table[each.key].name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy - Write Capacity
resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  provider = aws.project
  for_each = {
    for k, v in var.dynamo_config :
    k => v
    if v.autoscaling_enabled && v.autoscaling_write != null
  }

  name               = "${local.table_names[each.key]}-write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = each.value.autoscaling_write.target_utilization
    scale_in_cooldown  = each.value.autoscaling_write.scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling_write.scale_out_cooldown
  }
}
