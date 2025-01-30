###############################################################
# Variables Globales
###############################################################


aws_region        = "us-east-1"
profile           = "pra_idp_dev"
environment       = "dev"
client            = "pragma"
project           = "hefesto"
functionality     = "datos"  


common_tags = {
  environment   = "dev"
  project-name  = "Modulos Referencia"
  cost-center   = "-"
  owner         = "cristian.noguera@pragma.com.co"
  area          = "KCCC"
  provisioned   = "terraform"
  datatype      = "interno"
}


###############################################################
# Variables Dynamo
###############################################################
billing_mode    = "PAY_PER_REQUEST"
#read_capacity  = *Solo si es Provisioned*
#write_capacity = *Solo si es Provisioned*
hash_key        = "id"
range_key       = "value"
point_in_time_recovery = "true"
deletion_protection_enabled = false
server_side_encryption_enable = "true"
propagate_tags  = "true"
region_name     = "us-east-2"