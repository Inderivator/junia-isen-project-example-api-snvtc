provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "random_id" "random" {
  byte_length = 6
}

resource "azurerm_resource_group" "example" {
  name     = "shop-app-rg-${random_id.random.hex}"
  location = var.location
}

resource "azurerm_app_service_plan" "example" {
  name                = "shop-app-plan-${random_id.random.hex}"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "shop-app-${random_id.random.hex}"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id
}

module "vnet" {
  source = "./modules/vnet"
  resource_group_name = azurerm_resource_group.example.name
  location = var.location
  random_id = random_id.random.hex
  subnet_id_app_service = module.vnet.subnet_id_app_service
  subnet_id_db = module.vnet.subnet_id_db
}

module "database" {
    source = "./modules/bdd"
    resource_group_name = azurerm_resource_group.example.name
    username_db = var.username_db
    password_db = var.password_db
    random_id = random_id.random.hex
    vnet_id = module.vnet.vnet_id
    subnet_id_db = module.vnet.subnet_id_db
}
