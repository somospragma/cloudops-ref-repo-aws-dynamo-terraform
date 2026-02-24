# sample/main.tf
# Invocación del Módulo Padre (DynamoDB)
# Cumple con PC-IAC-026 (Patrón de Transformación en sample/)

############################################################################
# Invocación del Módulo Padre
############################################################################
module "dynamo" {
  source = "../" # Apunta al directorio padre (el módulo de referencia)

  providers = {
    aws.project = aws.principal
  }

  # Variables obligatorias de gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment
  application = var.application

  # Configuración transformada desde locals (PC-IAC-026)
  dynamo_config = local.dynamo_config_transformed
}
