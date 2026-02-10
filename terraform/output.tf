output "internal_ip_address_web1" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "internal_ip_address_web2" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}
