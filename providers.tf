provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

data "vault_kv_secret_v2" "aws" {
  mount = "kv"
  name  = "aws"
}

data "vault_kv_secret_v2" "ssh" {
  mount = "kv"
  name  = "ssh-default"
}

provider "aws" {
  region     = var.aws_region
  access_key = data.vault_kv_secret_v2.aws.data["access_key"]
  secret_key = data.vault_kv_secret_v2.aws.data["secret_key"]

  default_tags {
    tags = {
      Owner        = "gabriel.sre"
      Environment  = "dev"
      Project      = "homelab"
      CostCenter   = "TI-OBS001"
      BusinessUnit = "Plataforma"
      ManagedBy    = "Terraform"
    }
  }
}
