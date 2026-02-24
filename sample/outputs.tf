# sample/outputs.tf
# Outputs del ejemplo para validar la infraestructura creada

output "table_arns" {
  description = "ARNs of created DynamoDB tables"
  value       = module.dynamo.table_arns
}

output "table_names" {
  description = "Names of created DynamoDB tables"
  value       = module.dynamo.table_names
}

output "table_ids" {
  description = "IDs of created DynamoDB tables"
  value       = module.dynamo.table_ids
}
