resource "yandex_compute_snapshot_schedule" "web1" {
  name = "web1-snapshot-schedule"

  disk_ids = [yandex_compute_instance.web-disk1.boot_disk[0].disk_id]


  schedule_policy {
    expression = "0 2 * * *" # Ежедневно в 02:00 UTC
  }

  snapshot_count = 7

  depends_on = [yandex_compute_instance.zabbix]
}

resource "yandex_compute_snapshot_schedule" "web2" {
  name = "web2-snapshot-schedule"

  disk_ids = [yandex_compute_instance.web-disk2.boot_disk[0].disk_id]


  schedule_policy {
    expression = "0 2 * * *" # Ежедневно в 02:00 UTC
  }

  snapshot_count = 7

  depends_on = [yandex_compute_instance.zabbix]
}

resource "yandex_compute_snapshot_schedule" "zabbix" {
  name = "zabbix-snapshot-schedule"

  disk_ids = [yandex_compute_instance.zabbix.boot_disk[0].disk_id]


  schedule_policy {
    expression = "0 2 * * *" # Ежедневно в 02:00 UTC
  }

  snapshot_count = 7

  depends_on = [yandex_compute_instance.zabbix]
}

resource "yandex_compute_snapshot_schedule" "elastic" {
  name = "elastic-snapshot-schedule"

  disk_ids = [yandex_compute_instance.elastic.boot_disk.0.disk_id]

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7
}

resource "yandex_compute_snapshot_schedule" "kibana" {
  name = "kibana-snapshot-schedule"

  disk_ids = [yandex_compute_instance.kibana.boot_disk.0.disk_id]

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7
}

resource "yandex_compute_snapshot_schedule" "bastion" {
  name = "bastion-snapshot-schedule"

  disk_ids = [yandex_compute_instance.bastion.boot_disk.0.disk_id]

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7
}
