# outputs.tf
# Outputs del módulo DynamoDB
# Cumple con PC-IAC-007 (outputs granulares), PC-IAC-014 (splat expressions)

output "table_arns" {
  description = "Map of DynamoDB table ARNs by table key"
  value       = { for k, v in aws_dynamodb_table.dynamo_table : k => v.arn }
}

output "table_ids" {
  description = "Map of DynamoDB table IDs (names) by table key"
  value       = { for k, v in aws_dynamodb_table.dynamo_table : k => v.id }
}

output "table_names" {
  description = "Map of DynamoDB table names by table key"
  value       = local.table_names
}

output "table_stream_arns" {
  description = "Map of DynamoDB table stream ARNs by table key (only for tables with streams enabled)"
  value = {
    for k, v in aws_dynamodb_table.dynamo_table :
    k => v.stream_arn
    if v.stream_enabled != null && v.stream_enabled == true
  }
}

output "table_stream_labels" {
  description = "Map of DynamoDB table stream labels by table key (only for tables with streams enabled)"
  value = {
    for k, v in aws_dynamodb_table.dynamo_table :
    k => v.stream_label
    if v.stream_enabled != null && v.stream_enabled == true
  }
}

