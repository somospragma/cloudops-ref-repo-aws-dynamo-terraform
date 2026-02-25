# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

## [2.0.0] - 2026-02-24

### ⚠️ BREAKING CHANGES

#### Migración de GSI: hash_key/range_key → key_schema

Se ha migrado el patrón de definición de Global Secondary Indexes (GSI) de los atributos deprecados `hash_key` y `range_key` al nuevo patrón `key_schema` recomendado por AWS.

**Razón del Cambio:**
- Los atributos `hash_key` y `range_key` están deprecados en el provider AWS de Terraform
- El nuevo patrón `key_schema` soporta Multi-Attribute Keys (hasta 4 HASH + 4 RANGE keys)
- Elimina warnings de deprecación
- Alineado con las mejores prácticas de AWS

**Impacto:**
- Los consumidores del módulo deben actualizar su configuración de `global_secondary_indexes`
- Requiere cambios en archivos `.tfvars` existentes
- Puede requerir `terraform plan` para verificar impacto en infraestructura existente

**Migración Requerida:**

ANTES (v1.x):
```terraform
global_secondary_indexes = [
  {
    name            = "category-index"
    hash_key        = "category"
    range_key       = "price"
    projection_type = "ALL"
  }
]
```

DESPUÉS (v2.0):
```terraform
global_secondary_indexes = [
  {
    name = "category-index"
    key_schema = [
      {
        attribute_name = "category"
        key_type       = "HASH"
      },
      {
        attribute_name = "price"
        key_type       = "RANGE"
      }
    ]
    projection_type = "ALL"
  }
]
```

Ver `MIGRACION_GSI_KEY_SCHEMA.md` para guía completa de migración.

### Changed

- **Global Secondary Indexes:** Migrado de `hash_key`/`range_key` a `key_schema`
- **Validaciones:** Actualizadas para validar estructura de `key_schema`
- **Ejemplos:** Actualizados en `sample/terraform.tfvars` con nuevo patrón

### Added

- Soporte para Multi-Attribute Keys en GSI (hasta 4 HASH + 4 RANGE keys)
- Nueva validación: `key_type` debe ser "HASH" o "RANGE"
- Nueva validación: `key_schema` debe tener entre 1 y 8 definiciones de keys
- Documentación completa de migración en `MIGRACION_GSI_KEY_SCHEMA.md`
- Análisis detallado de warnings en `ANALISIS_WARNINGS_GSI.md`

### Removed

- ❌ Atributos deprecados `hash_key` y `range_key` en GSI
- ❌ Validaciones antiguas para `hash_key` y `range_key`

### Fixed

- ✅ Eliminados warnings de deprecación en `main.tf` líneas 76-77
- ✅ Código alineado con AWS Provider v6.33.0

---

## [1.1.0] - 2026-02-24

### Added
- ✨ **Global Secondary Indexes (GSI)** - Soporte completo para índices secundarios globales
  - Configuración de hash_key y range_key independientes
  - Projection types: ALL, KEYS_ONLY, INCLUDE
  - Capacidad independiente para tablas PROVISIONED
  - 6 validaciones para GSI
- ✨ **Local Secondary Indexes (LSI)** - Soporte completo para índices secundarios locales
  - Ordenamiento alternativo con la misma partition key
  - Projection types: ALL, KEYS_ONLY, INCLUDE
  - 4 validaciones para LSI
- ✨ **Auto Scaling** - Escalado automático para tablas PROVISIONED
  - Configuración independiente para read y write capacity
  - Target tracking con utilización configurable
  - Cooldown periods configurables
  - 6 validaciones para Auto Scaling
- ✨ **Time To Live (TTL)** - Eliminación automática de items expirados
  - Configuración simple con atributo de timestamp
  - Sin costo adicional
  - 1 validación para TTL
- 📊 Nuevos outputs:
  - `table_gsi_names` - Lista de nombres de GSI por tabla
  - `table_lsi_names` - Lista de nombres de LSI por tabla
  - `autoscaling_read_policy_arns` - ARNs de políticas de read scaling
  - `autoscaling_write_policy_arns` - ARNs de políticas de write scaling
- 📝 Ejemplo completo en `sample/terraform.tfvars` con todas las funcionalidades
- 📚 Documentación exhaustiva en `IMPLEMENTACION_GSI_LSI_AUTOSCALING_TTL.md`

### Changed
- Variables en `dynamo_config` ahora incluyen 4 nuevas configuraciones opcionales
- Ejemplo en `sample/` actualizado con tabla `inventory` demostrando todas las features

### Validation
- ✅ 11 validaciones nuevas agregadas (total: 19 validaciones)
- ✅ Retrocompatibilidad completa verificada
- ✅ Terraform validate exitoso
- ✅ Sin errores de diagnóstico

### Breaking Changes
- Ninguno - Todas las funcionalidades son opcionales con valores por defecto seguros

## [1.0.1] - 2026-02-23

### Added
- ✨ Soporte completo para DynamoDB Streams
  - Nueva variable `stream_enabled` (opcional, default: false)
  - Nueva variable `stream_view_type` (opcional, default: "NEW_AND_OLD_IMAGES")
  - Validación de `stream_view_type` con valores permitidos
  - Ejemplo en `sample/terraform.tfvars` con streams habilitado

### Fixed
- Corrección de error en outputs `table_stream_arns` y `table_stream_labels` cuando `stream_enabled` es null
- Uso de validación explícita `v.stream_enabled != null && v.stream_enabled == true` en condiciones de outputs
- Corrección de error en `lifecycle.prevent_destroy` - Cambiado a valor literal `true` (no puede ser dinámico)

### Changed
- `prevent_destroy` ahora es siempre `true` (no configurable por variable)
- Outputs de streams ahora funcionan correctamente cuando streams están habilitados

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
