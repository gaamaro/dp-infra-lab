module "ec2" {
  source         = "git::https://github.com/gaamaro/dp-tr-aws-ec2-module.git//ec2?ref=main"
  
  instance_name  = var.instance_name
  ssh_key_name   = data.vault_kv_secret_v2.ssh.data["key_name"]
  vault_token    = var.vault_token
}
