# **Módulo Terraform: cloudops-ref-repo-aws-dynamo-terraform**

## Descripción:

Este módulo permite la creación y gestión de tablas DynamoDB en AWS, facilitando la configuración de rendimiento, seguridad y alta disponibilidad.

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
└── environments/dev
    ├── terraform.tfvars
├── .gitignore
├── .terraform.lock.hcl
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/dynamodb/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/dynamodb/main.tf
module "dynamodb" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "dynamodb" {
  source = ""
  
  providers = {
    aws.principal = aws.principal
    aws.secondary = aws.secondary
  }

  # Common configuration 
  profile     = "profile01"
  aws_region  = "us-east-1"
  environment = "dev"
  client      = "cliente01"
  project     = "proyecto01"
  common_tags = {
    environment   = "dev"
    project-name  = "proyecto01"
    cost-center   = "xxxxxx"
    owner         = "xxxxxx"
    area          = "xxxxxx"
    provisioned   = "xxxxxx"
    datatype      = "xxxxxx"
  }

  # Dynamodb configuration 
  dynamodb_config [
    {
        billing_mode   = "xxxxxx"
        read_capacity  = "xxxxxx"
        write_capacity = "xxxxxx"
        hash_key       = "xxxxxx"
        range_key      = "xxxxxx"
        point_in_time_recovery = "xxxxxx"
        deletion_protection_enabled = "xxxxxx"
        attributes = {
            name = "xxxxxx"
            type = "xxxxxx"
        }
        server_side_encryption = {
          enabled = "xxxxxx"
          kms_key_arn = "xxxxxx"
        }
        replicas ={
          kms_key_arn = "xxxxxx"
          point_in_time_recovery = "xxxxxx"
          propagate_tags = "xxxxxx"
          region_name = "xxxxxx"
        }
      }
    ]
}
```

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
| [aws_dynamodb_global_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_global_table) | resource |
| [aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |


## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="billing_mode"></a> [billing_mode](#input\_billing_mode_) | Controls how you are charged for read and write throughput and how you manage capacity. | `string` | n/a | yes |
| <a name="read_capacity"></a> [read_capacity](#input\_read_capacity_) | Number of read units for this table. If the billing_mode is PROVISIONED, this field is required. | `number` | n/a | yes |
| <a name="write_capacity"></a> [write_capacity](#input\_write_capacity_) | Number of write units for this table. If the billing_mode is PROVISIONED, this field is required. | `number` | n/a | yes |
| <a name="hash_key"></a> [hash_key](#input\_hash_key_) | Name of the hash key in the index; must be defined as an attribute in the resource. | `string` | n/a | yes |
| <a name="range_key"></a> [range_key](#input\_range_key_) | Name of the range key; must be defined. | `string` | n/a | yes |
| <a name="point_in_time_recovery"></a> [point_in_time_recovery](#input\_point_in_time_recovery_) | Enable point-in-time recovery options. See below. | `string` | n/a | yes |
| <a name="deletion_protection_enabled"></a> [deletion_protection_enabled](#input\_deletion_protection_enabled_) | Enables deletion protection for table. Defaults to | `bool` | n/a | yes |
| <a name="name"></a> [name](#input\_name_) | (Required) Unique within a region name of the table. | `string` | n/a | yes |
| <a name="type"></a> [type](#input\_type_) | Required) Attribute type. Valid values are S (string), N (number), B (binary). | `string` | n/a | yes |
| <a name="enabled"></a> [enabled](#input\_enabled_) | (Required) Whether to enable point-in-time recovery. It can take 10 minutes to enable for new tables. If the point_in_time_recovery block is not provided. | `bool` | n/a | no |
| <a name="kms_key_arn"></a> [kms_key_arn](#input\_kms_key_arn_) | (Optional, Forces new resource) ARN of the CMK that should be used for the AWS KMS encryption. This argument should only be used if the key is different from the default KMS-managed DynamoDB key, alias/aws/dynamodb. | `string` | n/a | yes |
| <a name="propagate_tags"></a> [propagate_tags](#input\_propagate_tags_) | (Optional) Whether to propagate the global table's tags to a replica. Default is false. Changes to tags only move in one direction: from global (source) to replica. In other words, tag drift on a replica will not trigger an update. Tag or replica changes on the global table, whether from drift or configuration changes, are propagated to replicas. Changing from true to false on a subsequent apply means replica tags are left as they were, unmanaged, not deleted. | `string` | n/a | yes |
