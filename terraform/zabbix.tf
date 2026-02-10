resource "yandex_compute_disk" "zabbix-disk" {
  name     = "zabbix-disk"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = data.yandex_compute_image.main-image.id
}

resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.zabbix-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-public.id
    nat       = true
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }
}
