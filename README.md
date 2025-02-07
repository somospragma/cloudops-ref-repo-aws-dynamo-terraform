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
module "vpc" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "kms" {
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

  # Dynamo configuration 
  dynamo_config [
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
        functionality = "xxxxxx"
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


## Variables (Pendiente Description)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="billing_mode"></a> [billing_mode](#input\_billing_mode_) | If true, a global cluster will be created. | `bool` | n/a | yes |
| <a name="read_capacity"></a> [read_capacity](#input\_read_capacity_) | Cluster application name. | `string` | n/a | yes |
| <a name="write_capacity"></a> [write_capacity](#input\_write_capacity_) | Name of the database engine to be used for this DB cluster. Valid Values: aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters). | `string` | n/a | yes |
| <a name="hash_key"></a> [hash_key](#input\_hash_key_) | Database engine version. | `string` | n/a | yes |
| <a name="range_key"></a> [range_key](#input\_range_key_) | Data base name | `string` | n/a | yes |
| <a name="point_in_time_recovery"></a> [point_in_time_recovery](#input\_point_in_time_recovery_) | If the DB cluster should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false. | `bool` | n/a | yes |
| <a name="deletion_protection_enabled"></a> [deletion_protection_enabled](#input\_deletion_protection_enabled_) | If true, it'll be deploy only one node. | `bool` | n/a | yes |
| <a name="name"></a> [name](#input\_name_) | Database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless. | `string` | n/a | yes |
| <a name="type"></a> [type](#input\_type_) | Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if master_password is provided. | `bool` | n/a | yes |
| <a name="enabled"></a> [enabled](#input\_enabled_) | (Required unless manage_master_user_password is set to true or unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the "secondary" cluster of a global database) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the RDS Naming Constraints. Cannot be set if manage_master_user_password is set to true. | `string` | n/a | no |
| <a name="kms_key_arn"></a> [kms_key_arn](#input\_kms_key_arn_) | Master username for the database | `string` | n/a | yes |
| <a name="propagate_tags"></a> [propagate_tags](#input\_propagate_tags_) | Days to retain backups for. Default 1. | `number` | n/a | yes |
| <a name="functionality"></a> [functionality](#input\_functionality_) | Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false. | `bool` | n/a | yes |

## References (PENDIENTE)
