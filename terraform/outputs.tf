# ============================================================================
# 🔑 Внешние IP-адреса (публичный доступ)
# ============================================================================

output "bastion_public_ip" {
  description = "Внешний IP-адрес bastion-хоста для административного доступа"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "zabbix_public_ip" {
  description = "Внешний IP-адрес Zabbix-сервера (порт 80/443/10051)"
  value       = yandex_compute_instance.zabbix.network_interface[0].nat_ip_address
}

output "load_balancer_public_ip" {
  description = "Внешний IP-адрес сетевого балансировщика для веб-трафика"
  value       = yandex_lb_network_load_balancer.balancer.listener[0].external_address_spec[0].address
}

# ============================================================================
# 🌐 Внутренние IP-адреса (для диагностики и внутренних соединений)
# ============================================================================

output "bastion_private_ip" {
  description = "Внутренний IP bastion-хоста (для подключения к приватным хостам)"
  value       = yandex_compute_instance.bastion.network_interface[0].ip_address
}

output "zabbix_private_ip" {
  description = "Внутренний IP Zabbix-сервера (для мониторинга из приватной сети)"
  value       = yandex_compute_instance.zabbix.network_interface[0].ip_address
}

output "web_instance_group_target_group_id" {
  description = "ID целевой группы для балансировщика (для диагностики)"
  value       = yandex_compute_instance_group.web-instance-group.load_balancer[0].target_group_id
}

# ============================================================================
# 🔒 Инструкции по подключению (практическое применение)
# ============================================================================

output "ssh_to_bastion" {
  description = "Команда для SSH-подключения к bastion-хосту"
  value       = "ssh -i ~/.ssh/id_rsa ${var.vm_user}@${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}"
}

output "ssh_to_web_via_bastion" {
  description = "Команда для проксированного SSH-подключения к веб-серверам через bastion"
  value       = <<-EOT
  # Добавьте в ~/.ssh/config:
  Host bastion
    HostName ${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}
    User ${var.vm_user}
    IdentityFile ~/.ssh/id_rsa

  Host web-*
    ProxyJump bastion
    User ${var.vm_user}
    IdentityFile ~/.ssh/id_rsa
  EOT
}

output "web_access_url" {
  description = "URL для доступа к веб-приложению через балансировщик"
  value       = "http://${yandex_lb_network_load_balancer.balancer.listener[0].external_address_spec[0].address}"
}

output "zabbix_web_url" {
  description = "URL веб-интерфейса Zabbix"
  value       = "http://${yandex_compute_instance.zabbix.network_interface[0].nat_ip_address}"
}

# ============================================================================
# 📊 Метрики и статусы (для мониторинга развертывания)
# ============================================================================

output "web_instance_group_size" {
  description = "Текущее количество веб-серверов в группе"
  value       = yandex_compute_instance_group.web-instance-group.scale_policy[0].auto_scale[0].initial_size
}

output "web_instance_group_zones" {
  description = "Зоны доступности, где развернуты веб-серверы"
  value       = yandex_compute_instance_group.web-instance-group.allocation_policy[0].zones
}

output "vpc_network_id" {
  description = "ID VPC-сети (для отладки и интеграций)"
  value       = yandex_vpc_network.main-network.id
}

# ============================================================================
# ⚠️ Предупреждения безопасности (важно!)
# ============================================================================

output "security_warning" {
  description = "ВАЖНО: напоминание о безопасности"
  value       = <<-EOT
  ⚠️  ВАЖНО: 
  1. SSH на bastion открыт для 0.0.0.0/0 — в продакшене ограничьте своим IP!
  2. Zabbix имеет публичный доступ — настройте аутентификацию и фаервол.
  3. Сохраните terraform.tfstate в безопасном месте (не коммитьте в Git!).
  EOT
}
