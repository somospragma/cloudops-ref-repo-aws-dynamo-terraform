# Ejemplo de Uso del Módulo DynamoDB

Este directorio contiene un ejemplo funcional de cómo usar el módulo DynamoDB siguiendo el patrón PC-IAC-026.

## 📋 Estructura del Ejemplo

```
sample/
├── README.md           # Este archivo
├── terraform.tfvars    # Configuración declarativa
├── variables.tf        # Definición de variables
├── data.tf            # Data sources para IDs dinámicos
├── locals.tf          # Transformaciones de configuración
├── main.tf            # Invocación del módulo
├── outputs.tf         # Outputs del ejemplo
└── providers.tf       # Configuración de providers
```

## 🔄 Flujo de Datos (PC-IAC-026)

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → módulo
    (config)        (tipos)     (consulta)  (transform)  (invoca)
```

### 1. `terraform.tfvars`
Configuración declarativa sin IDs hardcodeados. Los campos vacíos (`""`) se llenan automáticamente.

### 2. `data.tf`
Obtiene recursos existentes (KMS keys) mediante data sources.

### 3. `locals.tf`
Transforma la configuración inyectando IDs dinámicos desde data sources.

### 4. `main.tf`
Solo invoca el módulo con la configuración transformada desde `local.*`.

## 🚀 Cómo Ejecutar

### Prerrequisitos

1. KMS key existente con alias: `{client}-{project}-{environment}-kms-dynamodb`
2. AWS CLI configurado con perfil apropiado
3. Terraform >= 1.0.0

### Pasos

1. **Configurar variables:**
   ```bash
   # Editar terraform.tfvars con tus valores
   vim terraform.tfvars
   ```

2. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

3. **Validar configuración:**
   ```bash
   terraform validate
   terraform fmt -check
   ```

4. **Revisar plan:**
   ```bash
   terraform plan
   ```

5. **Aplicar cambios:**
   ```bash
   terraform apply
   ```

## 🔑 Variables Importantes

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `client` | Nombre del cliente | `pragma` |
| `project` | Nombre del proyecto | `ecommerce` |
| `environment` | Ambiente | `dev`, `qa`, `pdn` |
| `application` | Nombre de la aplicación | `orders` |
| `dynamo_config` | Configuración de tablas | Ver `terraform.tfvars` |

## 📝 Notas

- Los KMS key ARNs se inyectan automáticamente desde data sources
- Si `kms_key_arn` está vacío en `terraform.tfvars`, se usa el data source
- El cifrado es obligatorio (validado en el módulo)
- `prevent_destroy` está habilitado por defecto

## 🧪 Testing

```bash
# Verificar que el plan no tiene errores
terraform plan -out=tfplan

# Verificar outputs
terraform output
```

## 🧹 Limpieza

⚠️ **ADVERTENCIA:** Las tablas tienen `prevent_destroy = true`. Para eliminarlas:

1. Comentar `prevent_destroy` en el módulo
2. Ejecutar `terraform apply`
3. Ejecutar `terraform destroy`

```bash
# Destruir recursos (después de deshabilitar prevent_destroy)
terraform destroy
```
