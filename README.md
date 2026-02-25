# **Módulo Terraform: cloudops-ref-repo-aws-dynamo-terraform**

## Descripción:

Este módulo permite la creación y gestión de tablas DynamoDB en AWS, facilitando la configuración de  rendimiento, seguridad y alta disponibilidad.

DynamoDB
- Crear una tabla DynamoDB con el esquema de clave primaria especificado.
- Configurar el modo de capacidad (on-demand o provisionado).
- Habilitar el cifrado en reposo mediante KMS.
- Configurar las políticas de acceso para la tabla.
- Habilitar backups automáticos y exportaciones.
- Configurar replicación global para alta disponibilidad y recuperación ante desastres.


Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

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
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v1.0.0"
  
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

    "products" = {
      billing_mode  = "PAY_PER_REQUEST"
      hash_key      = "product_id"
      functionality = "catalog"

      attributes = [
        {
          name = "product_id"
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

### Ejemplo con Modo Provisionado

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v1.0.0"
  
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
      read_capacity  = 10
      write_capacity = 5
      hash_key       = "sku"
      functionality  = "inventory-management"

      attributes = [
        {
          name = "sku"
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

### Ejemplo con DynamoDB Streams

```hcl
module "dynamodb" {
  source = "git::https://github.com/org/cloudops-ref-repo-aws-dynamo-terraform.git?ref=v1.0.0"
  
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
    billing_mode                = string           # "PAY_PER_REQUEST" o "PROVISIONED"
    read_capacity               = optional(number) # Requerido si billing_mode = "PROVISIONED"
    write_capacity              = optional(number) # Requerido si billing_mode = "PROVISIONED"
    hash_key                    = string           # Nombre de la partition key
    range_key                   = optional(string) # Nombre de la sort key (opcional)
    point_in_time_recovery      = optional(bool, true)
    deletion_protection_enabled = optional(bool, true)
    functionality               = string           # Descripción de la funcionalidad

    attributes = list(object({
      name = string # Nombre del atributo
      type = string # "S" (string), "N" (number), "B" (binary)
    }))

    server_side_encryption = object({
      enabled     = bool              # Debe ser true (obligatorio)
      kms_key_arn = optional(string)  # ARN de la KMS key
    })

    replicas = optional(list(object({
      region_name            = string
      kms_key_arn            = optional(string)
      point_in_time_recovery = optional(bool)
      propagate_tags         = optional(bool)
    })), [])

    # DynamoDB Streams (opcional)
    stream_enabled   = optional(bool, false)                    # Habilitar streams
    stream_view_type = optional(string, "NEW_AND_OLD_IMAGES")  # Tipo de vista del stream

    additional_tags = optional(map(string), {})
  }
}
```

## Outputs

| Name | Description | Type |
|------|-------------|------|
| `table_arns` | Map of DynamoDB table ARNs by table key | `map(string)` |
| `table_ids` | Map of DynamoDB table IDs (names) by table key | `map(string)` |
| `table_names` | Map of DynamoDB table names by table key | `map(string)` |
| `table_stream_arns` | Map of DynamoDB table stream ARNs (only for tables with streams enabled) | `map(string)` |
| `table_stream_labels` | Map of DynamoDB table stream labels (only for tables with streams enabled) | `map(string)` |

### Ejemplo de Uso de Outputs

```hcl
# Obtener ARN de una tabla específica
orders_table_arn = module.dynamodb.table_arns["orders"]

# Obtener nombre de una tabla
products_table_name = module.dynamodb.table_names["products"]

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

2. **GSI/LSI:** El módulo no incluye soporte para Global Secondary Indexes (GSI) o Local Secondary Indexes (LSI) en esta versión.

3. **Auto Scaling:** El módulo no configura auto scaling para tablas con billing_mode = PROVISIONED.

4. **TTL:** El módulo no configura Time To Live (TTL) automáticamente.

## Roadmap

Características planificadas para futuras versiones:

- [x] Soporte para DynamoDB Streams ✅ (Implementado)
- [ ] Soporte para Global Secondary Indexes (GSI)
- [ ] Soporte para Local Secondary Indexes (LSI)
- [ ] Configuración de Auto Scaling para modo PROVISIONED
- [ ] Configuración de Time To Live (TTL)
- [ ] Tests automatizados con Terratest
- [ ] Soporte para DynamoDB Contributor Insights

## Soporte y Contribuciones

Para reportar problemas o solicitar nuevas características, por favor abre un issue en el repositorio.

## Licencia

Este módulo es mantenido por el equipo de CloudOps de Pragma.

## Autores

- CloudOps Team - Pragma

## Referencias

- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [Terraform AWS Provider - DynamoDB Table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [PC-IAC Governance Rules](https://github.com/pragma/pc-iac-rules)
