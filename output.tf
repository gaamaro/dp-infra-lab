output "ec2_id" {
  description = "ID da instância EC2 criada"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "IP público da instância"
  value       = module.ec2.public_ip
}

output "ec2_ssh" {
  description = "Comando SSH sugerido para conectar na instância"
  value       = module.ec2.ssh_connect
}
