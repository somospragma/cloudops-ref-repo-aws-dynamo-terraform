# sample/locals.tf
# Transformaciones y valores locales del ejemplo
# Cumple con PC-IAC-026 (Patrón de Transformación en sample/)

locals {
  # Prefijo de gobernanza para el ejemplo
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Transformar configuración inyectando KMS key ARN dinámico (PC-IAC-026)
  dynamo_config_transformed = {
    for key, config in var.dynamo_config : key => merge(config, {
      # Si kms_key_arn está vacío, inyectar desde data source
      kms_key_arn = length(try(config.kms_key_arn, "")) > 0 ? config.kms_key_arn : data.aws_kms_key.dynamodb.arn

      # Transformar server_side_encryption
      server_side_encryption = {
        enabled     = config.server_side_encryption.enabled
        kms_key_arn = length(try(config.server_side_encryption.kms_key_arn, "")) > 0 ? config.server_side_encryption.kms_key_arn : data.aws_kms_key.dynamodb.arn
      }
    })
  }
}
