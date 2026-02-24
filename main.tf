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
  # lifecycle {
  #   prevent_destroy = true
  # }
}

