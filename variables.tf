variable "instance_name" {
  description = "Nome da instância EC2"
  type        = string
}

variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "vault_token" {
  description = "Token de autenticação no Vault"
  type        = string
  sensitive   = true
}

variable "vault_addr" {
  description = "Endereço do Vault"
  type        = string
}
