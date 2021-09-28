resource "azurerm_resource_group" "LoadBalancerTFRG" {
  name     = "LoadBalancerTFRG"
  location = "East US"
}

resource "azurerm_virtual_network" "LoadBalancerTFvNet" {
  name                = "LoadBalancerTFvNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.LoadBalancerTFRG.location
  resource_group_name = azurerm_resource_group.LoadBalancerTFRG.name
}

resource "azurerm_subnet" "LoadBalancerTFSubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.LoadBalancerTFRG.name
  virtual_network_name = azurerm_virtual_network.LoadBalancerTFvNet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "LoadBalancerTFNIC" {
  name                = "LoadBalancerTFNIC"
  location            = azurerm_resource_group.LoadBalancerTFRG.location
  resource_group_name = azurerm_resource_group.LoadBalancerTFRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.LoadBalancerTFSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.LoadBalancerTFPubIP.id
  }
}

resource "azurerm_linux_virtual_machine" "LoadBalancerTFVM" {
  name                            = "LoadBalancerTFVM"
  resource_group_name             = azurerm_resource_group.LoadBalancerTFRG.name
  location                        = azurerm_resource_group.LoadBalancerTFRG.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Lenovo21!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.LoadBalancerTFNIC.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "LoadBalancerTFPubIP" {
  name                = "LoadBalancerTFPubIP"
  location            = azurerm_resource_group.LoadBalancerTFRG.location
  resource_group_name = azurerm_resource_group.LoadBalancerTFRG.name
  allocation_method   = "Dynamic"
}
