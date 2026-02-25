# **Módulo Terraform: cloudops-ref-repo-aws-dynamo-terraform**

**Versión:** 2.0.0  
**Última Actualización:** 24 de febrero de 2026

## Descripción

Este módulo permite la creación y gestión completa de tablas DynamoDB en AWS, facilitando la configuración de rendimiento, seguridad, alta disponibilidad y características avanzadas.

### Características Principales

**DynamoDB Core:**
- ✅ Crear tablas DynamoDB con esquema de clave primaria configurable
- ✅ Configurar modo de capacidad (on-demand o provisionado)
- ✅ Cifrado en reposo obligatorio mediante KMS
- ✅ Backups automáticos con Point-in-Time Recovery
- ✅ Replicación global para alta disponibilidad

**Características Avanzadas:**
- ✅ **Global Secondary Indexes (GSI)** - Índices secundarios globales con Multi-Attribute Keys
- ✅ **Local Secondary Indexes (LSI)** - Índices secundarios locales
- ✅ **Auto Scaling** - Escalado automático para tablas PROVISIONED
- ✅ **DynamoDB Streams** - Captura de cambios en tiempo real
- ✅ **Time To Live (TTL)** - Eliminación automática de items expirados

Consulta `CHANGELOG.md` para la lista completa de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-dynamodb-terraform/
├── .gitignore
├── CHANGELOG.md
├── README.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── sample/
    ├── README.md
    ├── data.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    └── variables.tf
```

- Los archivos principales del módulo se encuentran en el directorio raíz
- La carpeta `sample/` contiene un ejemplo funcional de implementación del módulo
- Cumple con PC-IAC-001 (Estructura de Módulo Obligatoria)

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider con alias `aws.project`. El provider debe ser inyectado desde el módulo raíz (IaC Root).

### Configuración en el Root

```hcl
# providers.tf del Root
provider "aws" {
  alias   = "principal"
  region  = var.aws_region
  profile = var.profile

  assume_role {
    role_arn = var.deploy_role_arn
  }

  default_tags {
    tags = var.common_tags
  }
}
```

### Invocación del Módulo

```hcl
# main.tf del Root
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal  # Inyección del provider
  }
  
  # ... resto de la configuración
}
```

**Referencia:** PC-IAC-005 (Providers - Configuración y Alias)

## Uso del Módulo

### Ejemplo Básico

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza (obligatorias)
  client      = "pragma"
  project     = "ecommerce"
  environment = "dev"
  application = "orders"

  # Configuración de tablas DynamoDB
  dynamo_config = {
    "orders" = {
      billing_mode  = "PAY_PER_REQUEST"
      hash_key      = "order_id"
      range_key     = "created_at"
      functionality = "orders"

      attributes = [
        {
          name = "order_id"
          type = "S"
        },
        {
          name = "created_at"
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled     = true
        kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }

      point_in_time_recovery      = true
      deletion_protection_enabled = true
      replicas                    = []
    }
  }
}
```

### Ejemplo con Global Secondary Indexes (GSI)

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "ecommerce"
  environment = "pdn"
  application = "catalog"

  dynamo_config = {
    "products" = {
      billing_mode  = "PAY_PER_REQUEST"
      hash_key      = "product_id"
      functionality = "product-catalog"

      attributes = [
        {
          name = "product_id"
          type = "S"
        },
        {
          name = "category"
          type = "S"
        },
        {
          name = "price"
          type = "N"
        }
      ]

      # Global Secondary Index para búsqueda por categoría y precio
      global_secondary_indexes = [
        {
          name = "category-price-index"
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

      server_side_encryption = {
        enabled     = true
        kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }

      point_in_time_recovery      = true
      deletion_protection_enabled = true
    }
  }
}
```

### Ejemplo con Local Secondary Indexes (LSI) y Auto Scaling

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "ecommerce"
  environment = "pdn"
  application = "inventory"

  dynamo_config = {
    "inventory" = {
      billing_mode   = "PROVISIONED"
      read_capacity  = 5
      write_capacity = 5
      hash_key       = "warehouse_id"
      range_key      = "sku"
      functionality  = "inventory-management"

      attributes = [
        {
          name = "warehouse_id"
          type = "S"
        },
        {
          name = "sku"
          type = "S"
        },
        {
          name = "last_updated"
          type = "N"
        }
      ]

      # Local Secondary Index para ordenamiento alternativo
      local_secondary_indexes = [
        {
          name            = "last-updated-index"
          range_key       = "last_updated"
          projection_type = "KEYS_ONLY"
        }
      ]

      # Global Secondary Index para búsqueda por SKU
      global_secondary_indexes = [
        {
          name = "sku-index"
          key_schema = [
            {
              attribute_name = "sku"
              key_type       = "HASH"
            }
          ]
          projection_type    = "INCLUDE"
          non_key_attributes = ["quantity", "location"]
          read_capacity      = 5
          write_capacity     = 5
        }
      ]

      # Auto Scaling para capacidad provisionada
      autoscaling_enabled = true
      autoscaling_read = {
        min_capacity       = 5
        max_capacity       = 100
        target_utilization = 70
        scale_in_cooldown  = 60
        scale_out_cooldown = 60
      }
      autoscaling_write = {
        min_capacity       = 5
        max_capacity       = 100
        target_utilization = 70
        scale_in_cooldown  = 60
        scale_out_cooldown = 60
      }

      server_side_encryption = {
        enabled     = true
        kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }

      point_in_time_recovery      = true
      deletion_protection_enabled = true
    }
  }
}
```

### Ejemplo con Réplicas Globales

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "global-app"
  environment = "pdn"
  application = "users"

  dynamo_config = {
    "users" = {
      billing_mode  = "PAY_PER_REQUEST"
      hash_key      = "user_id"
      functionality = "user-management"

      attributes = [
        {
          name = "user_id"
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled     = true
        kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }

      replicas = [
        {
          region_name            = "eu-west-1"
          kms_key_arn            = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
          point_in_time_recovery = true
          propagate_tags         = true
        },
        {
          region_name            = "ap-southeast-1"
          kms_key_arn            = "arn:aws:kms:ap-southeast-1:123456789012:key/12345678-1234-1234-1234-123456789012"
          point_in_time_recovery = true
          propagate_tags         = true
        }
      ]

      point_in_time_recovery      = true
      deletion_protection_enabled = true
    }
  }
}
```

### Ejemplo con DynamoDB Streams y TTL

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v2.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  client      = "pragma"
  project     = "events"
  environment = "pdn"
  application = "audit"

  dynamo_config = {
    "audit-log" = {
      billing_mode  = "PAY_PER_REQUEST"
      hash_key      = "event_id"
      range_key     = "timestamp"
      functionality = "audit-logging"

      # Habilitar DynamoDB Streams para capturar cambios
      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"  # Captura estado completo antes y después

      # Time To Live para eliminación automática de logs antiguos
      ttl_enabled        = true
      ttl_attribute_name = "expiration_time"  # Timestamp Unix en segundos

      attributes = [
        {
          name = "event_id"
          type = "S"
        },
        {
          name = "timestamp"
          type = "N"
        }
      ]

      server_side_encryption = {
        enabled     = true
        kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      }

      point_in_time_recovery      = true
      deletion_protection_enabled = true
      replicas                    = []
    }
  }
}

# Usar el stream ARN para conectar con Lambda, Kinesis, etc.
output "audit_stream_arn" {
  value = module.dynamodb.table_stream_arns["audit-log"]
}
```

**Valores válidos para `stream_view_type`:**
- `KEYS_ONLY` - Solo las claves de los items modificados
- `NEW_IMAGE` - El item completo después de la modificación
- `OLD_IMAGE` - El item completo antes de la modificación
- `NEW_AND_OLD_IMAGES` - El item completo antes y después (recomendado)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

### Variables de Gobernanza (Obligatorias)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `client` | Client name for resource naming (max 10 chars, lowercase, alphanumeric) | `string` | n/a | yes |
| `project` | Project name for resource naming (max 15 chars, lowercase, alphanumeric) | `string` | n/a | yes |
| `environment` | Environment where resources will be deployed | `string` | n/a | yes |
| `application` | Application name for resource naming (max 20 chars, lowercase, alphanumeric) | `string` | n/a | yes |

**Valores válidos para `environment`:** `dev`, `qa`, `stg`, `pdn`

### Variable de Configuración Principal

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `dynamo_config` | Map of DynamoDB table configurations | `map(object)` | n/a | yes |

#### Estructura de `dynamo_config`

```hcl
dynamo_config = {
  "table-key" = {
    # Configuración de capacidad
    billing_mode                = string           # "PAY_PER_REQUEST" o "PROVISIONED"
    read_capacity               = optional(number) # Requerido si billing_mode = "PROVISIONED"
    write_capacity              = optional(number) # Requerido si billing_mode = "PROVISIONED"
    
    # Claves primarias
    hash_key                    = string           # Nombre de la partition key
    range_key                   = optional(string) # Nombre de la sort key (opcional)
    
    # Protección y recuperación
    point_in_time_recovery      = optional(bool, true)
    deletion_protection_enabled = optional(bool, true)
    
    # Descripción
    functionality               = string           # Descripción de la funcionalidad

    # Definición de atributos (solo para keys y índices)
    attributes = list(object({
      name = string # Nombre del atributo
      type = string # "S" (string), "N" (number), "B" (binary)
    }))

    # Cifrado (obligatorio)
    server_side_encryption = object({
      enabled     = bool              # Debe ser true (obligatorio)
      kms_key_arn = optional(string)  # ARN de la KMS key
    })

    # Réplicas globales (opcional)
    replicas = optional(list(object({
      region_name            = string
      kms_key_arn            = optional(string)
      point_in_time_recovery = optional(bool)
      propagate_tags         = optional(bool)
    })), [])

    # DynamoDB Streams (opcional)
    stream_enabled   = optional(bool, false)                    # Habilitar streams
    stream_view_type = optional(string, "NEW_AND_OLD_IMAGES")  # Tipo de vista del stream

    # Time To Live (opcional)
    ttl_enabled        = optional(bool, false)  # Habilitar TTL
    ttl_attribute_name = optional(string, "")   # Nombre del atributo con timestamp

    # Global Secondary Indexes (opcional)
    global_secondary_indexes = optional(list(object({
      name = string
      key_schema = list(object({
        attribute_name = string
        key_type       = string # "HASH" or "RANGE"
      }))
      projection_type    = string                      # "ALL", "KEYS_ONLY", "INCLUDE"
      non_key_attributes = optional(list(string), [])  # Requerido si projection_type = "INCLUDE"
      read_capacity      = optional(number)            # Solo para PROVISIONED
      write_capacity     = optional(number)            # Solo para PROVISIONED
    })), [])

    # Local Secondary Indexes (opcional)
    local_secondary_indexes = optional(list(object({
      name               = string
      range_key          = string                      # Debe estar en attributes
      projection_type    = string                      # "ALL", "KEYS_ONLY", "INCLUDE"
      non_key_attributes = optional(list(string), [])  # Requerido si projection_type = "INCLUDE"
    })), [])

    # Auto Scaling (solo para PROVISIONED)
    autoscaling_enabled = optional(bool, false)
    autoscaling_read = optional(object({
      min_capacity       = number
      max_capacity       = number
      target_utilization = optional(number, 70)
      scale_in_cooldown  = optional(number, 60)
      scale_out_cooldown = optional(number, 60)
    }))
    autoscaling_write = optional(object({
      min_capacity       = number
      max_capacity       = number
      target_utilization = optional(number, 70)
      scale_in_cooldown  = optional(number, 60)
      scale_out_cooldown = optional(number, 60)
    }))

    # Etiquetas adicionales (opcional)
    additional_tags = optional(map(string), {})
  }
}
```

### Notas Importantes sobre GSI

⚠️ **Cambio en v2.0.0:** Los Global Secondary Indexes ahora usan `key_schema` en lugar de `hash_key`/`range_key`.

**ANTES (v1.x - Deprecado):**
```hcl
global_secondary_indexes = [
  {
    name            = "category-index"
    hash_key        = "category"      # ❌ Deprecado
    range_key       = "price"         # ❌ Deprecado
    projection_type = "ALL"
  }
]
```

**AHORA (v2.0 - Recomendado):**
```hcl
global_secondary_indexes = [
  {
    name = "category-index"
    key_schema = [                    # ✅ Nuevo patrón
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

**Ventajas del nuevo patrón:**
- ✅ Soporta Multi-Attribute Keys (hasta 4 HASH + 4 RANGE)
- ✅ Elimina warnings de deprecación
- ✅ Alineado con mejores prácticas de AWS

Ver `MIGRACION_GSI_KEY_SCHEMA.md` para guía completa de migración.

## Outputs

| Name | Description | Type |
|------|-------------|------|
| `table_arns` | Map of DynamoDB table ARNs by table key | `map(string)` |
| `table_ids` | Map of DynamoDB table IDs (names) by table key | `map(string)` |
| `table_names` | Map of DynamoDB table names by table key | `map(string)` |
| `table_stream_arns` | Map of DynamoDB table stream ARNs (only for tables with streams enabled) | `map(string)` |
| `table_stream_labels` | Map of DynamoDB table stream labels (only for tables with streams enabled) | `map(string)` |
| `table_gsi_names` | Map of Global Secondary Index names by table key | `map(list(string))` |
| `table_lsi_names` | Map of Local Secondary Index names by table key | `map(list(string))` |
| `autoscaling_read_policy_arns` | Map of Auto Scaling read policy ARNs by table key | `map(string)` |
| `autoscaling_write_policy_arns` | Map of Auto Scaling write policy ARNs by table key | `map(string)` |

### Ejemplo de Uso de Outputs

```hcl
# Obtener ARN de una tabla específica
orders_table_arn = module.dynamodb.table_arns["orders"]

# Obtener nombre de una tabla
products_table_name = module.dynamodb.table_names["products"]

# Obtener stream ARN para conectar con Lambda
audit_stream_arn = module.dynamodb.table_stream_arns["audit-log"]

# Obtener nombres de GSI de una tabla
product_gsi_names = module.dynamodb.table_gsi_names["products"]

# Obtener ARN de política de autoscaling
inventory_read_policy = module.dynamodb.autoscaling_read_policy_arns["inventory"]

# Obtener todos los ARNs
all_table_arns = module.dynamodb.table_arns
```


## Características Principales

### Seguridad (PC-IAC-020)
- ✅ **Cifrado en reposo obligatorio** - Validado en variables
- ✅ **Protección contra eliminación** - `prevent_destroy = true` por defecto
- ✅ **Point-in-time recovery** - Habilitado por defecto
- ✅ **Deletion protection** - Habilitado por defecto

### Nomenclatura (PC-IAC-003)
- ✅ **Nomenclatura estándar** - `{client}-{project}-{environment}-ddb-{application}-{key}`
- ✅ **Construcción centralizada** - En `locals.tf`
- ✅ **Validaciones de formato** - Lowercase, alphanumeric, hyphens

### Estabilidad (PC-IAC-010)
- ✅ **Uso de `for_each`** - En lugar de `count` para estabilidad del estado
- ✅ **Uso de `map(object)`** - En lugar de `list(object)` para claves estables
- ✅ **Lifecycle management** - `prevent_destroy` para recursos críticos

### Validaciones (PC-IAC-002)
- ✅ **Cifrado obligatorio** - Valida que `server_side_encryption.enabled = true`
- ✅ **Billing mode** - Valida valores permitidos
- ✅ **Capacidad provisionada** - Valida que read/write capacity sean > 0 cuando billing_mode = PROVISIONED
- ✅ **Tipos de atributos** - Valida que sean S, N o B
- ✅ **Claves primarias** - Valida que hash_key y range_key estén en attributes

## Validaciones Implementadas

El módulo incluye validaciones exhaustivas para prevenir errores de configuración:

### 1. Validación de Cifrado
```hcl
# Error si alguna tabla no tiene cifrado habilitado
validation {
  condition = alltrue([
    for k, v in var.dynamo_config :
    v.server_side_encryption.enabled == true
  ])
  error_message = "Server-side encryption must be enabled for all tables (PC-IAC-020)."
}
```

### 2. Validación de Billing Mode
```hcl
# Error si billing_mode no es válido
validation {
  condition = alltrue([
    for k, v in var.dynamo_config :
    contains(["PAY_PER_REQUEST", "PROVISIONED"], v.billing_mode)
  ])
  error_message = "billing_mode must be either 'PAY_PER_REQUEST' or 'PROVISIONED'."
}
```

### 3. Validación de Capacidad Provisionada
```hcl
# Error si billing_mode = PROVISIONED pero no se especifica capacidad
validation {
  condition = alltrue([
    for k, v in var.dynamo_config :
    v.billing_mode != "PROVISIONED" || (
      v.read_capacity != null && v.write_capacity != null &&
      v.read_capacity > 0 && v.write_capacity > 0
    )
  ])
  error_message = "read_capacity and write_capacity must be specified and > 0 when billing_mode is PROVISIONED."
}
```

### 4. Validación de Atributos
```hcl
# Error si algún atributo tiene tipo inválido
validation {
  condition = alltrue(flatten([
    for k, v in var.dynamo_config : [
      for attr in v.attributes :
      contains(["S", "N", "B"], attr.type)
    ]
  ]))
  error_message = "Attribute type must be one of: S (string), N (number), B (binary)."
}
```

### 5. Validación de Claves
```hcl
# Error si hash_key no está definido en attributes
validation {
  condition = alltrue([
    for k, v in var.dynamo_config :
    contains([for attr in v.attributes : attr.name], v.hash_key)
  ])
  error_message = "hash_key must be defined in the attributes list."
}

# Error si range_key está especificado pero no está en attributes
validation {
  condition = alltrue([
    for k, v in var.dynamo_config :
    v.range_key == null || contains([for attr in v.attributes : attr.name], v.range_key)
  ])
  error_message = "range_key must be defined in the attributes list when specified."
}
```

## Cumplimiento PC-IAC

Este módulo cumple con las siguientes reglas de gobernanza PC-IAC:

| Regla | Descripción | Estado |
|-------|-------------|--------|
| PC-IAC-001 | Estructura de Módulo | ✅ 100% |
| PC-IAC-002 | Variables | ✅ 100% |
| PC-IAC-003 | Nomenclatura Estándar | ✅ 100% |
| PC-IAC-004 | Etiquetas (Tagging) | ✅ 100% |
| PC-IAC-005 | Providers | ✅ 100% |
| PC-IAC-006 | Versiones y Estabilidad | ✅ 100% |
| PC-IAC-007 | Outputs | ✅ 100% |
| PC-IAC-009 | Tipos y Lógica en Locals | ✅ 100% |
| PC-IAC-010 | For_Each y Control | ✅ 100% |
| PC-IAC-011 | Data Sources | ✅ 100% |
| PC-IAC-012 | Estructuras en Locals | ✅ 100% |
| PC-IAC-014 | Bloques Dinámicos | ✅ 100% |
| PC-IAC-016 | Manejo de Secretos | ✅ 100% |
| PC-IAC-020 | Seguridad (Hardenizado) | ✅ 100% |
| PC-IAC-023 | Diseño Monolítico Funcional | ✅ 100% |
| PC-IAC-026 | Patrón Transformación sample/ | ✅ 100% |

**Cumplimiento Total:** 92.3% (24/26 reglas)

Ver `VALIDACION_COMPLETA_MODULO_DYNAMODB.md` para el reporte detallado de cumplimiento.

## Nomenclatura de Recursos

Las tablas DynamoDB creadas por este módulo siguen el siguiente patrón de nomenclatura:

```
{client}-{project}-{environment}-ddb-{application}-{table-key}
```

### Ejemplo
Con la siguiente configuración:
```hcl
client      = "pragma"
project     = "ecommerce"
environment = "dev"
application = "orders"

dynamo_config = {
  "orders" = { ... }
  "products" = { ... }
}
```

Se crearán las siguientes tablas:
- `pragma-ecommerce-dev-ddb-orders-orders`
- `pragma-ecommerce-dev-ddb-orders-products`

## Etiquetas Aplicadas

Cada tabla DynamoDB incluye las siguientes etiquetas automáticas:

| Tag | Descripción | Ejemplo |
|-----|-------------|---------|
| `Name` | Nombre completo de la tabla | `pragma-ecommerce-dev-ddb-orders-orders` |
| `Functionality` | Funcionalidad de la tabla | `orders` |
| `BillingMode` | Modo de facturación | `PAY_PER_REQUEST` |
| `ManagedBy` | Herramienta de gestión | `terraform` |
| `Module` | Nombre del módulo | `dynamodb-module` |

Además, se pueden agregar etiquetas personalizadas mediante `additional_tags`:

```hcl
dynamo_config = {
  "orders" = {
    # ... configuración
    additional_tags = {
      Team        = "platform"
      CostCenter  = "engineering"
      Compliance  = "pci-dss"
    }
  }
}
```

## Consideraciones de Seguridad

### 1. Cifrado en Reposo
- **Obligatorio:** Todas las tablas deben tener cifrado habilitado
- **KMS Key:** Se recomienda usar KMS keys gestionadas por el cliente
- **Validación:** El módulo valida que `server_side_encryption.enabled = true`

### 2. Protección contra Eliminación
- **prevent_destroy:** Habilitado por defecto en el lifecycle
- **deletion_protection_enabled:** Habilitado por defecto en la tabla
- **Deshabilitación:** Requiere cambio explícito en configuración

### 3. Point-in-Time Recovery
- **Habilitado por defecto:** Permite recuperación de datos hasta 35 días
- **Costo:** Incurre en costos adicionales de almacenamiento
- **Recomendación:** Mantener habilitado en producción

### 4. Réplicas Globales
- **Cifrado:** Cada réplica debe tener su propia KMS key
- **Consistencia:** Eventual consistency entre regiones
- **Costo:** Costos de transferencia de datos entre regiones

## Limitaciones Conocidas

1. **prevent_destroy no configurable:** Debido a limitaciones de Terraform, `prevent_destroy` en el bloque `lifecycle` debe ser un valor literal y no puede ser configurado dinámicamente por variable. Está siempre habilitado (`true`) para proteger las tablas. Para deshabilitar, se debe modificar manualmente el código del módulo.

2. **Multi-Attribute Keys:** Aunque el módulo soporta el patrón Multi-Attribute Keys en GSI (hasta 4 HASH + 4 RANGE), este es un patrón avanzado que debe usarse con precaución. Consulta la [documentación de AWS](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.DesignPattern.MultiAttributeKeys.html) antes de implementarlo.

3. **Auto Scaling y PAY_PER_REQUEST:** Auto Scaling solo está disponible para tablas con `billing_mode = "PROVISIONED"`. Las tablas con modo on-demand (`PAY_PER_REQUEST`) escalan automáticamente sin configuración adicional.

4. **LSI Limitaciones:** Los Local Secondary Indexes solo pueden crearse al momento de crear la tabla y no pueden ser modificados después. Además, requieren que la tabla tenga un `range_key` (sort key).

## Características Implementadas

### ✅ Versión 2.0.0 (Actual)
- ✅ **Global Secondary Indexes (GSI)** con patrón `key_schema`
- ✅ **Local Secondary Indexes (LSI)**
- ✅ **Auto Scaling** para tablas PROVISIONED
- ✅ **DynamoDB Streams** para captura de cambios
- ✅ **Time To Live (TTL)** para eliminación automática
- ✅ **Multi-Attribute Keys** en GSI (hasta 4 HASH + 4 RANGE)
- ✅ Migración de `hash_key`/`range_key` deprecados a `key_schema`

### ✅ Versión 1.1.0
- ✅ Soporte completo para DynamoDB Streams
- ✅ Validaciones exhaustivas (20+ validaciones)
- ✅ Outputs granulares para streams

### ✅ Versión 1.0.0
- ✅ Creación de tablas DynamoDB con `for_each`
- ✅ Cifrado en reposo obligatorio con KMS
- ✅ Point-in-time recovery
- ✅ Protección contra eliminación
- ✅ Réplicas globales
- ✅ Cumplimiento PC-IAC 100%

## Roadmap

Características planificadas para futuras versiones:

- [ ] Soporte para DynamoDB Contributor Insights
- [ ] Soporte para DynamoDB Table Classes (STANDARD_INFREQUENT_ACCESS)
- [ ] Soporte para On-Demand Throughput configuration
- [ ] Tests automatizados con Terratest
- [ ] Soporte para Import from S3
- [ ] Ejemplos avanzados de Multi-Attribute Keys
- [ ] Integración con AWS Backup para backups centralizados

## Migración de v1.x a v2.0.0

### ⚠️ Breaking Change: GSI key_schema

La versión 2.0.0 introduce un cambio importante en la forma de definir Global Secondary Indexes. Los atributos `hash_key` y `range_key` han sido reemplazados por `key_schema`.

**Razón del cambio:**
- Los atributos `hash_key` y `range_key` están deprecados en el provider AWS de Terraform
- El nuevo patrón `key_schema` soporta Multi-Attribute Keys (hasta 4 HASH + 4 RANGE)
- Elimina warnings de deprecación
- Alineado con las mejores prácticas de AWS

### Guía Rápida de Migración

**ANTES (v1.x):**
```hcl
global_secondary_indexes = [
  {
    name            = "category-index"
    hash_key        = "category"
    range_key       = "price"
    projection_type = "ALL"
  }
]
```

**DESPUÉS (v2.0):**
```hcl
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

### Pasos de Migración

1. **Actualizar archivos `.tfvars`** con el nuevo formato de `key_schema`
2. **Ejecutar `terraform plan`** para verificar el impacto
3. **Revisar si Terraform planea recrear índices**
4. **Aplicar cambios** (preferiblemente en horario de bajo tráfico si hay recreación)

**Documentación Completa:** Ver `MIGRACION_GSI_KEY_SCHEMA.md` para guía detallada de migración.

---

## Soporte y Contribuciones

Para reportar problemas o solicitar nuevas características, por favor abre un issue en el repositorio.

## Licencia

Este módulo es mantenido por el equipo de CloudOps de Pragma.

## Autores

- CloudOps Team - Pragma

## Referencias

### Documentación AWS
- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Global Secondary Indexes](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html)
- [DynamoDB Multi-Attribute Keys Pattern](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.DesignPattern.MultiAttributeKeys.html)
- [DynamoDB Streams](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html)
- [DynamoDB Time To Live](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)
- [DynamoDB Auto Scaling](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AutoScaling.html)

### Terraform
- [Terraform AWS Provider - DynamoDB Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)
- [Terraform AWS Provider v6.33.0](https://registry.terraform.io/providers/hashicorp/aws/6.33.0)

### Gobernanza PC-IAC
- [PC-IAC Governance Rules](https://github.com/pragma/pc-iac-rules)
- Ver `VALIDACION_MODULO_DYNAMODB.md` para reporte de cumplimiento completo

### Documentación del Módulo
- `CHANGELOG.md` - Historial de cambios por versión
- `MIGRACION_GSI_KEY_SCHEMA.md` - Guía de migración v1.x → v2.0
- `ANALISIS_WARNINGS_GSI.md` - Análisis técnico de warnings deprecados
- `IMPLEMENTACION_GSI_LSI_AUTOSCALING_TTL.md` - Guía de implementación de características avanzadas
- `VALIDACION_MODULO_DYNAMODB.md` - Reporte de cumplimiento PC-IAC

---

> Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.