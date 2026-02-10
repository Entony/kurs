resource "yandex_compute_snapshot_schedule" "daily" {
  name = "daily-snapshots"

  snapshot_spec {
    description = "Daily snapshot"
    # Добавляем все диски ВМ через dynamic block
    dynamic "disk_id" {
      for_each = flatten([
        yandex_compute_instance.web[*].boot_disk.0.disk_id,
        yandex_compute_instance.zabbix[0].boot_disk.0.disk_id,
        yandex_compute_instance.elastic[0].boot_disk.0.disk_id,
        yandex_compute_instance.kibana[0].boot_disk.0.disk_id,
        yandex_compute_instance.bastion[0].boot_disk.0.disk_id
      ])
      content {
        disk_id = disk_id.value
      }
    }

    snapshot_count = 7 # Хранение 7 дней
  }

  schedule_policy {
    expression = "0 2 * * *" # Ежедневно в 02:00 UTC
  }
}
