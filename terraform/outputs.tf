# ============================================================================
# Внешние IP-адреса (публичный доступ)
# ============================================================================

output "bastion_public_ip" {
  description = "Внешний IP-адрес bastion-хоста для административного доступа"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "zabbix_public_ip" {
  description = "Внешний IP-адрес Zabbix-сервера (порт 80/443/10051)"
  value       = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

output "alb_public_ip" {
  description = "Публичный IP Application Load Balancer"
  value       = yandex_alb_load_balancer.web-alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}


