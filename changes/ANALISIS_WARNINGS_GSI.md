# 🔍 Análisis de Warnings en Global Secondary Indexes

**Archivo:** `main.tf`  
**Líneas:** 76-77  
**Fecha:** 24 de febrero de 2026

---

## ⚠️ Warnings Detectados

```terraform
# main.tf (líneas 76-77)
dynamic "global_secondary_index" {
  for_each = each.value.global_secondary_indexes
  content {
    name               = global_secondary_index.value.name
    hash_key           = global_secondary_index.value.hash_key      # ⚠️ WARNING
    range_key          = global_secondary_index.value.range_key     # ⚠️ WARNING
    projection_type    = global_secondary_index.value.projection_type
    non_key_attributes = ...
    read_capacity      = ...
    write_capacity     = ...
  }
}
```

**Mensaje de Warning:**
```
Saw Warning: "hash_key" is deprecated: Reason: ""
Saw Warning: "range_key" is deprecated: Reason: ""
```

---

## 📚 Causa del Warning (Documentación Oficial)

Según la documentación oficial del provider AWS de Terraform (versión 6.33.0):

### Argumentos Deprecados en `global_secondary_index`:

```terraform
# ❌ DEPRECADO (genera warnings)
global_secondary_index {
  hash_key  = "attribute_name"  # Deprecated
  range_key = "attribute_name"  # Deprecated
}

# ✅ RECOMENDADO (nuevo patrón)
global_secondary_index {
  key_schema {
    attribute_name = "attribute_name"
    key_type       = "HASH"
  }
  key_schema {
    attribute_name = "attribute_name"
    key_type       = "RANGE"
  }
}
```

### Extracto de la Documentación:

> **`hash_key`** - (Optional, **Deprecated**) Name of the hash key in the index; must be defined as an attribute in the resource. **Mutually exclusive with `key_schema`. Use `key_schema` instead.**

> **`range_key`** - (Optional, **Deprecated**) Name of the range key; must be defined as an attribute in the resource. **Mutually exclusive with `key_schema`. Use `key_schema` instead.**

---

## 🎯 Razón de la Deprecación

AWS introdujo el patrón **Multi-Attribute Keys** para Global Secondary Indexes, que permite:

1. **Múltiples HASH keys** (hasta 4)
2. **Múltiples RANGE keys** (hasta 4)
3. **Mayor flexibilidad** en el diseño de índices

El nuevo bloque `key_schema` soporta este patrón avanzado, mientras que `hash_key` y `range_key` solo soportan el patrón tradicional de 1 HASH + 1 RANGE.

### Ejemplo del Patrón Multi-Attribute Keys:

```terraform
# Patrón avanzado: Múltiples HASH y RANGE keys
global_secondary_index {
  name = "TournamentRegionIndex"
  
  # Múltiples HASH keys
  key_schema {
    attribute_name = "tournamentId"
    key_type       = "HASH"
  }
  key_schema {
    attribute_name = "region"
    key_type       = "HASH"
  }
  
  # Múltiples RANGE keys
  key_schema {
    attribute_name = "round"
    key_type       = "RANGE"
  }
  key_schema {
    attribute_name = "bracket"
    key_type       = "RANGE"
  }
  key_schema {
    attribute_name = "matchId"
    key_type       = "RANGE"
  }
  
  projection_type = "ALL"
}
```

---

## 🔧 Solución Recomendada

### Opción 1: Migrar a `key_schema` (Recomendado)

**Ventajas:**
- ✅ Elimina los warnings
- ✅ Soporta patrones avanzados en el futuro
- ✅ Alineado con las mejores prácticas de AWS
- ✅ Compatible con el patrón Multi-Attribute Keys

**Desventajas:**
- ⚠️ Requiere cambios en `variables.tf` y `main.tf`
- ⚠️ Puede requerir recreación de índices (verificar con `terraform plan`)

#### Cambios Necesarios:

**1. Actualizar `variables.tf`:**

```terraform
# variables.tf - ANTES (deprecado)
global_secondary_indexes = optional(list(object({
  name               = string
  hash_key           = string                    # ❌ Deprecado
  range_key          = optional(string)          # ❌ Deprecado
  projection_type    = string
  non_key_attributes = optional(list(string), [])
  read_capacity      = optional(number)
  write_capacity     = optional(number)
})), [])

# variables.tf - DESPUÉS (recomendado)
global_secondary_indexes = optional(list(object({
  name            = string
  key_schema = list(object({                     # ✅ Nuevo
    attribute_name = string
    key_type       = string  # "HASH" o "RANGE"
  }))
  projection_type    = string
  non_key_attributes = optional(list(string), [])
  read_capacity      = optional(number)
  write_capacity     = optional(number)
})), [])
```

**2. Actualizar `main.tf`:**

```terraform
# main.tf - ANTES (deprecado)
dynamic "global_secondary_index" {
  for_each = each.value.global_secondary_indexes
  content {
    name               = global_secondary_index.value.name
    hash_key           = global_secondary_index.value.hash_key      # ❌
    range_key          = global_secondary_index.value.range_key     # ❌
    projection_type    = global_secondary_index.value.projection_type
    non_key_attributes = ...
    read_capacity      = ...
    write_capacity     = ...
  }
}

# main.tf - DESPUÉS (recomendado)
dynamic "global_secondary_index" {
  for_each = each.value.global_secondary_indexes
  content {
    name            = global_secondary_index.value.name
    
    # ✅ Nuevo bloque key_schema
    dynamic "key_schema" {
      for_each = global_secondary_index.value.key_schema
      content {
        attribute_name = key_schema.value.attribute_name
        key_type       = key_schema.value.key_type
      }
    }
    
    projection_type    = global_secondary_index.value.projection_type
    non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" 
      ? global_secondary_index.value.non_key_attributes 
      : null
    read_capacity      = each.value.billing_mode == "PROVISIONED" 
      ? global_secondary_index.value.read_capacity 
      : null
    write_capacity     = each.value.billing_mode == "PROVISIONED" 
      ? global_secondary_index.value.write_capacity 
      : null
  }
}
```

**3. Actualizar `sample/terraform.tfvars`:**

```terraform
# sample/terraform.tfvars - ANTES (deprecado)
global_secondary_indexes = [
  {
    name            = "category-index"
    hash_key        = "category"        # ❌
    range_key       = "price"           # ❌
    projection_type = "ALL"
  }
]

# sample/terraform.tfvars - DESPUÉS (recomendado)
global_secondary_indexes = [
  {
    name = "category-index"
    key_schema = [                      # ✅
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

**4. Actualizar validaciones en `variables.tf`:**

```terraform
# Validación ANTES (deprecado)
validation {
  condition = alltrue(flatten([
    for k, v in var.dynamo_config : [
      for gsi in v.global_secondary_indexes :
      contains([for attr in v.attributes : attr.name], gsi.hash_key)
    ]
  ]))
  error_message = "GSI hash_key must be defined in the attributes list."
}

# Validación DESPUÉS (recomendado)
validation {
  condition = alltrue(flatten([
    for k, v in var.dynamo_config : [
      for gsi in v.global_secondary_indexes : [
        for ks in gsi.key_schema :
        contains([for attr in v.attributes : attr.name], ks.attribute_name)
      ]
    ]
  ]))
  error_message = "All GSI key_schema attributes must be defined in the attributes list."
}

validation {
  condition = alltrue(flatten([
    for k, v in var.dynamo_config : [
      for gsi in v.global_secondary_indexes : [
        for ks in gsi.key_schema :
        contains(["HASH", "RANGE"], ks.key_type)
      ]
    ]
  ]))
  error_message = "GSI key_schema key_type must be either 'HASH' or 'RANGE'."
}
```

---

### Opción 2: Mantener el Código Actual (No Recomendado)

**Ventajas:**
- ✅ No requiere cambios inmediatos
- ✅ El código sigue funcionando

**Desventajas:**
- ❌ Warnings persistentes
- ❌ Código deprecado que puede ser removido en futuras versiones
- ❌ No soporta patrones avanzados
- ❌ No alineado con mejores prácticas

**Nota:** Los atributos `hash_key` y `range_key` aún funcionan, pero están marcados como deprecados y podrían ser removidos en versiones futuras del provider.

---

## 📋 Plan de Migración Recomendado

### Fase 1: Preparación (Sin Impacto)

1. ✅ Crear rama de desarrollo: `feature/migrate-gsi-key-schema`
2. ✅ Actualizar `variables.tf` con nueva estructura
3. ✅ Actualizar validaciones
4. ✅ Actualizar `main.tf` con bloques `key_schema`
5. ✅ Actualizar `sample/terraform.tfvars` con ejemplos

### Fase 2: Testing (Ambiente Dev)

1. ✅ Ejecutar `terraform plan` en ambiente dev
2. ✅ Verificar si Terraform planea recrear los índices
3. ✅ Si hay recreación, evaluar impacto en aplicaciones
4. ✅ Ejecutar `terraform apply` en dev
5. ✅ Validar que los índices funcionan correctamente

### Fase 3: Documentación

1. ✅ Actualizar `README.md` con nueva estructura
2. ✅ Actualizar `CHANGELOG.md` con breaking change
3. ✅ Crear guía de migración para consumidores del módulo

### Fase 4: Despliegue (Ambientes Superiores)

1. ✅ Aplicar en QA
2. ✅ Aplicar en STG
3. ✅ Aplicar en PDN (con ventana de mantenimiento si hay recreación)

---

## ⚠️ Consideraciones de Impacto

### ¿La Migración Recreará los Índices?

**Depende del estado actual de Terraform:**

1. **Si los índices ya existen en AWS:**
   - Terraform puede detectar que solo cambió la forma de declarar el índice
   - Puede NO recrear los índices (solo actualizar el estado)
   - **Recomendación:** Ejecutar `terraform plan` primero para verificar

2. **Si Terraform planea recrear:**
   ```
   # aws_dynamodb_table.dynamo_table["products"] will be updated in-place
   ~ resource "aws_dynamodb_table" "dynamo_table" {
       ~ global_secondary_index {
           - hash_key  = "category" -> null
           - range_key = "price" -> null
           + key_schema {
               + attribute_name = "category"
               + key_type       = "HASH"
             }
           + key_schema {
               + attribute_name = "price"
               + key_type       = "RANGE"
             }
         }
     }
   ```

3. **Impacto de Recreación:**
   - ⚠️ El índice estará temporalmente no disponible
   - ⚠️ Las consultas que usan el índice fallarán
   - ⚠️ Tiempo de recreación: depende del tamaño de la tabla
   - ⚠️ Costo: puede generar costos de escritura durante la recreación

### Mitigación de Riesgos:

1. **Ejecutar en horario de bajo tráfico**
2. **Notificar a equipos de aplicación**
3. **Tener plan de rollback**
4. **Monitorear métricas de DynamoDB durante la migración**

---

## 🎯 Recomendación Final

### Para Ambiente de Desarrollo:
✅ **MIGRAR INMEDIATAMENTE** a `key_schema`
- Los warnings indican código deprecado
- Es mejor migrar ahora que esperar a que sea obligatorio
- Alineado con mejores prácticas de AWS

### Para Ambientes de Producción:
⚠️ **PLANIFICAR MIGRACIÓN CON CUIDADO**
1. Probar primero en dev/qa
2. Verificar impacto con `terraform plan`
3. Coordinar ventana de mantenimiento si hay recreación
4. Tener plan de rollback

### Alternativa Temporal:
Si no es posible migrar inmediatamente, puedes:
1. Documentar el warning en el README
2. Crear un ticket para migración futura
3. Mantener el código actual funcionando

---

## 📚 Referencias

- [AWS DynamoDB Multi-Attribute Keys Pattern](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.DesignPattern.MultiAttributeKeys.html)
- [Terraform AWS Provider - DynamoDB Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)
- [Terraform AWS Provider v6.33.0 Documentation](https://registry.terraform.io/providers/hashicorp/aws/6.33.0)

---

**Conclusión:** Los warnings son legítimos y señalan que `hash_key` y `range_key` están deprecados en favor de `key_schema`. Se recomienda migrar al nuevo patrón para eliminar los warnings y alinearse con las mejores prácticas de AWS.
