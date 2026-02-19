// 1. DATABASE: Managed PostgreSQL (кластер из 2 нод)
resource "yandex_mdb_postgresql_cluster" "zabbix-db" {
  name        = "zabbix-pg-cluster"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.main-network.id
  version     = "14"

  resources {
    resource_preset_id = "s2.micro" // min-конфигурация
    disk_size          = 10
    disk_type_id       = "network-hdd"
  }

  host {
    zone_id          = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.subnet-a.id
    assign_public_ip = false
  }

  host {
    zone_id          = "ru-central1-b"
    subnet_id        = yandex_vpc_subnet.subnet-b.id
    assign_public_ip = false
  }

  // Автоматический failover
  postgresql_config {
    max_connections = 100
    shared_buffers  = "256MB"
  }

  user {
    name     = "zabbix"
    password = var.db_password
    permission {
      database_name = "zabbixdb"
    }
  }

  database {
    name  = "zabbixdb"
    owner = "zabbix"
  }
}

// 2. SERVER: Ядро Zabbix (в приватной подсети)
resource "yandex_compute_instance" "zabbix-server" {
  name = "zabbix-server"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4 // рекомендовано для Zabbix Server
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.main_image.id
      type     = "network-ssd"
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-a.id // приватная подсеть
    security_group_ids = [yandex_vpc_security_group.zabbix-server-sg.id]
    nat                = false // нет публичного IP
  }

  metadata = {
    user-data = templatefile("zabbix-server.tpl", {
      DB_HOST = yandex_mdb_postgresql_cluster.zabbix-db.host[0].fqdn
      DB_USER = "zabbix"
      DB_PASS = var.db_password
    })
  }
}

// 3. FRONTEND: Веб‑интерфейс (в публичной подсети)
resource "yandex_compute_instance" "zabbix-frontend" {
  name = "zabbix-frontend"
  zone = "ru-central1-a"

  resources {
    cores  = 1
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.main_image.id
      type     = "network-ssd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-public.id // публичная подсеть
    security_group_ids = [yandex_vpc_security_group.zabbix-frontend-sg.id]
    nat                = true // публичный IP
  }

  metadata = {
    user-data = templatefile("zabbix-frontend.tpl", {
      SERVER_IP = yandex_compute_instance.zabbix-server.network_interface[0].ip_address
    })
  }
}



