# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Fixed
- Corrección de error en outputs `table_stream_arns` y `table_stream_labels` cuando `stream_enabled` es null
- Uso de validación explícita `v.stream_enabled != null && v.stream_enabled == true` en condiciones de outputs

## [1.0.0] - 2026-02-23

### Added
- Implementación inicial del módulo DynamoDB con cumplimiento PC-IAC
- Soporte para múltiples tablas mediante `for_each` (PC-IAC-010)
- Cifrado en reposo obligatorio con KMS (PC-IAC-020)
- Point-in-time recovery habilitado por defecto
- Protección contra eliminación con `prevent_destroy`
- Soporte para réplicas globales
- Validaciones exhaustivas en variables (PC-IAC-002)
- Ejemplo funcional en `sample/` siguiendo PC-IAC-026
- Documentación completa de cumplimiento PC-IAC

### Changed
- Migración de `count` a `for_each` para estabilidad del estado
- Cambio de `list(object)` a `map(object)` en variables
- Nomenclatura centralizada en `locals.tf` (PC-IAC-003)
- Outputs granulares con mapas en lugar de listas (PC-IAC-007)

### Security
- Validación obligatoria de cifrado en todas las tablas
- `prevent_destroy` habilitado por defecto
- Valores por defecto seguros para configuraciones críticas
- Validación de tipos de atributos y claves

### Breaking Changes
- ⚠️ Cambio de `list(object)` a `map(object)` requiere actualización de configuración
- ⚠️ Cambio de `count` a `for_each` requiere migración de estado para recursos existentes
- ⚠️ Outputs ahora devuelven mapas en lugar de listas

### Migration Guide
Para migrar de versiones anteriores:

1. **Actualizar configuración de variables:**
   ```hcl
   # Antes
   dynamo_config = [
     { ... }
   ]
   
   # Después
   dynamo_config = {
     "table-key" = { ... }
   }
   ```

2. **Migrar estado de Terraform:**
   ```bash
   # Para cada tabla existente
   terraform state mv 'aws_dynamodb_table.dynamo_table[0]' 'aws_dynamodb_table.dynamo_table["table-key"]'
   ```

3. **Actualizar referencias a outputs:**
   ```hcl
   # Antes
   table_arn = module.dynamodb.table_info[0].table_arn
   
   # Después
   table_arn = module.dynamodb.table_arns["table-key"]
   ```
