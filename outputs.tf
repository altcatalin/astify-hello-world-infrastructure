output "service_endpoint" {
  value = "http://${azurerm_public_ip.this.ip_address}:${local.service_port}"
}
