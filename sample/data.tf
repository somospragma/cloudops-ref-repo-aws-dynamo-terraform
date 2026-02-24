# sample/data.tf
# Data sources para el ejemplo
# Obtiene recursos existentes para inyección dinámica (PC-IAC-026)

# Obtener KMS key por alias para cifrado de DynamoDB
data "aws_kms_key" "dynamodb" {
  provider = aws.principal
  key_id   = "alias/${var.client}-${var.project}-${var.environment}-kms-dynamodb"
}

# Ejemplo: Obtener VPC si se necesita para VPC endpoints (opcional)
# data "aws_vpc" "selected" {
#   provider = aws.principal
#   
#   filter {
#     name   = "tag:Name"
#     values = ["${var.client}-${var.project}-${var.environment}-vpc"]
#   }
# }
