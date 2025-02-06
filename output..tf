output "table_info" {
  value = [for table in aws_dynamodb_table.dynamo_table : {"table_arn" : table.arn}]
}
