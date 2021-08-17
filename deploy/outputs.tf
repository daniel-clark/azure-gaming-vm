output "instance_ip" {
	value = azurerm_public_ip.main_ip.ip_address
}

output "admin_username" {
	value = local.admin_username
}

output "admin_password" {
	value = random_password.admin_password.result
	sensitive = true
}