provider "azurerm" {
	features {}
	subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
	name = local.resource_group_name
	location = var.location
}

resource "azurerm_virtual_network" "main_vnet" {
	name				= "${local.resource_prefix}-vnet"
	address_space		= ["10.0.0.0/16"]
	location			= azurerm_resource_group.main.location
	resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_group" "main_nsg" {
	name				= "${local.resource_prefix}-nsg"
	location			= azurerm_resource_group.main.location
	resource_group_name	= azurerm_resource_group.main.name

	security_rule {
		name = "SSH"
		priority = 100
		direction = "Inbound"
		access = "Allow"
		protocol = "*"
		source_port_range = "*"
		destination_port_range = "22"
		source_address_prefix = "*"
		destination_address_prefix = "*"
	} 
}

resource "azurerm_subnet" "main_subnet" {
name				 = "internal"
resource_group_name	= azurerm_resource_group.main.name
virtual_network_name = azurerm_virtual_network.main_vnet.name
address_prefixes	= ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main_ip" {
	name				= "main_ip"
	location			= azurerm_resource_group.main.location
	resource_group_name = azurerm_resource_group.main.name
	allocation_method	= "Static"
}

resource "azurerm_network_interface" "main_nic" {
	name				= "main_nic"
	location			= azurerm_resource_group.main.location
	resource_group_name = azurerm_resource_group.main.name

	ip_configuration {
	name							= "internal"
	subnet_id						= azurerm_subnet.main_subnet.id
	private_ip_address_allocation	= "Dynamic"
	public_ip_address_id			= azurerm_public_ip.main_ip.id
	}
}

resource "random_password" "admin_password" {
	length = 22
	special = true
	override_special = "_%@"
}

resource "azurerm_windows_virtual_machine" "main_vm" {
	name				= "${var.user_initials}-azgaming"
	resource_group_name = azurerm_resource_group.main.name
	location			= azurerm_resource_group.main.location
	# priority			= "Spot"
	# max_bid_price		= 0.6
	# eviction_policy	 = "Deallocate"
	size				= var.vm_size
	admin_username		= local.admin_username
	admin_password		= random_password.admin_password.result
	allow_extension_operations = true
	network_interface_ids = [azurerm_network_interface.main_nic.id,]

	os_disk {
		caching					= "ReadWrite"
		storage_account_type	= "Standard_LRS"
	}

	source_image_reference {
		publisher	= "MicrosoftWindowsServer"
		offer		= "WindowsServer"
		sku			= "2019-Datacenter"
		version		= "latest"
	}
}

resource "azurerm_virtual_machine_extension" "gpudrivers" {
	name					= "NvidiaGpuDrivers"
	virtual_machine_id		= azurerm_windows_virtual_machine.main_vm.id
	publisher				= "Microsoft.HpcCompute"
	type					= "NvidiaGpuDriverWindows"
	type_handler_version	= "1.3"
	auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "configureforansbile" {
	name					= "ConfigureAnsible"
	virtual_machine_id		= azurerm_windows_virtual_machine.main_vm.id
	publisher				= "Microsoft.Compute"
	type					= "CustomScriptExtension"
	type_handler_version	= "1.9"
	settings = <<SETTINGS
	{
		"commandToExecute": "powershell .\\ConfigureRemotingForAnsible.ps1",
		"fileUris" : ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
	 }
	SETTINGS
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main_vm_shutdown" {
	virtual_machine_id = azurerm_windows_virtual_machine.main_vm.id
	location = azurerm_resource_group.main.location
	enabled = true

	daily_recurrence_time = "2330"
	timezone = "UTC"
  
	notification_settings {
	  enabled = false
	}
}