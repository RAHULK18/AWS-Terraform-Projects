output "master_public_ip" {
  value = module.mysql_master.public_ip
}

output "slave_public_ip" {
  value = module.mysql_slave.public_ip
}

output "master_private_ip" {
  value = module.mysql_master.private_ip
}

output "slave_private_ip" {
  value = module.mysql_slave.private_ip
}
