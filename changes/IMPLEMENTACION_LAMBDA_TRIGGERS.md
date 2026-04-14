# Implementación de Lambda Triggers para DynamoDB Streams

**Fecha:** 13 de abril de 2026  
**Versión:** 2.1.0

## Descripción

Se añade soporte para configurar Lambda Triggers (event source mappings) que conectan DynamoDB Streams con funciones Lambda directamente desde el módulo, eliminando la necesidad de crear el recurso `aws_lambda_event_source_mapping` externamente.

## Archivos Modificados

| Archivo | Cambio |
|---------|--------|
| `variables.tf` | Nuevo atributo `lambda_triggers` en `dynamo_config` + 9 validaciones |
| `locals.tf` | Nuevo local `lambda_trigger_map` para aplanar triggers en mapa `for_each` |
| `main.tf` | Nuevo recurso `aws_lambda_event_source_mapping.dynamodb_trigger` |
| `outputs.tf` | 2 nuevos outputs: `lambda_trigger_arns`, `lambda_trigger_uuids` |
| `sample/variables.tf` | Actualizado type con `lambda_triggers` |
| `sample/terraform.tfvars` | Ejemplo de trigger en tabla `products` |
| `sample/outputs.tf` | Nuevos outputs para triggers |
| `README.md` | Documentación completa con ejemplo, tabla de parámetros y outputs |

## Características del Lambda Trigger

- **Batch processing:** Configurable de 1 a 10000 registros por invocación
- **Paralelización:** Hasta 10 batches concurrentes por shard
- **Dead Letter Queue:** Soporte para SQS/SNS como destino de fallos
- **Event filtering:** Filtrado de eventos antes de invocar Lambda
- **Bisect on error:** División automática de batch en caso de error
- **Tumbling windows:** Ventanas de agregación para streaming analytics
- **Batch failure reporting:** Soporte para `ReportBatchItemFailures`
- **Retry control:** Configuración de reintentos y edad máxima de registros

## Validaciones Añadidas

1. `stream_enabled` debe ser `true` cuando hay `lambda_triggers`
2. `starting_position` debe ser `LATEST` o `TRIM_HORIZON`
3. `batch_size` entre 1 y 10000
4. `parallelization_factor` entre 1 y 10
5. `maximum_batching_window_in_seconds` entre 0 y 300
6. `tumbling_window_in_seconds` entre 0 y 900
7. `function_response_types` solo acepta `ReportBatchItemFailures`
8. `maximum_record_age_in_seconds` debe ser -1 o entre 60 y 604800
9. `maximum_retry_attempts` debe ser -1 o entre 0 y 10000

## Patrón de Diseño

Los triggers se aplanan en `locals.tf` usando un mapa con claves `"{table_key}-{index}"`, permitiendo múltiples triggers por tabla y manteniendo el patrón `for_each` del módulo (PC-IAC-010).

## Consideraciones

- El módulo **no crea** funciones Lambda ni colas SQS/SNS — recibe sus ARNs como input
- La dependencia con `aws_dynamodb_table` se resuelve implícitamente al referenciar `stream_arn`
- El provider `aws.project` se reutiliza consistentemente
- Compatible con tablas en modo `PAY_PER_REQUEST` y `PROVISIONED`
