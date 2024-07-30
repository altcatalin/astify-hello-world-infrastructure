locals {
  service_port = 3000
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = data.azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_subnet" "private" {
  name                 = "${data.azurerm_resource_group.this.name}-private"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "this" {
  name                = data.azurerm_resource_group.this.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "public" {
  name                = "${data.azurerm_resource_group.this.name}-public"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_network_interface" "private" {
  name                = "${data.azurerm_resource_group.this.name}-private"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "default" {
  name                = "${data.azurerm_resource_group.this.name}-default"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  #trivy:ignore:avd-azu-0047
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = local.service_port
    source_address_prefix      = "*"
    destination_port_range     = local.service_port
    destination_address_prefix = azurerm_network_interface.public.private_ip_address
  }

  dynamic "security_rule" {
    for_each = var.admin_ssh_allowed_ips

    content {
      access                     = "Allow"
      direction                  = "Inbound"
      name                       = "ssh-${security_rule.value}"
      priority                   = 200 + security_rule.key
      protocol                   = "Tcp"
      source_port_range          = "22"
      source_address_prefix      = security_rule.value
      destination_port_range     = "22"
      destination_address_prefix = azurerm_network_interface.public.private_ip_address
    }
  }
}

resource "azurerm_network_interface_security_group_association" "default" {
  network_interface_id      = azurerm_network_interface.private.id
  network_security_group_id = azurerm_network_security_group.default.id
}

data "azurerm_image" "this" {
  name                = var.source_image_name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = data.azurerm_resource_group.this.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  size                = "Standard_B2ats_v2"
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_key)
  }

  network_interface_ids = [
    azurerm_network_interface.public.id,
    azurerm_network_interface.private.id,
  ]

  source_image_id = data.azurerm_image.this.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
