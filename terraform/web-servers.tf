resource "yandex_compute_disk" "web-disk1" {
  name     = "web-disk1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = 20
  image_id = data.yandex_compute_image.main_image.id
}

resource "yandex_compute_disk" "web-disk2" {
  name     = "web-disk2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 20
  image_id = data.yandex_compute_image.main_image.id
}

resource "yandex_compute_instance" "web1" {
  name = "web1"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.web-disk1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-a.id
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
    nat                = false
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }


}

resource "yandex_compute_instance" "web2" {
  name = "web2"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.web-disk2.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-b.id
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
    nat                = false
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }


}

# Target Group
resource "yandex_alb_target_group" "web-tg" {
  name      = "web-target-group"
  folder_id = var.folder_id

  target {
    subnet_id  = yandex_vpc_subnet.subnet-a.id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-b.id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}


# Backend Group
resource "yandex_alb_backend_group" "web-bg" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    target_group_ids = [yandex_alb_target_group.web-tg.id]
    port             = 80

    load_balancing_config {
      mode = "ROUND_ROBIN"
    }

    healthcheck {
      http_healthcheck {
        path = "/"
      }
      timeout             = "10s"
      interval            = "30s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }
}

# HTTP Router
resource "yandex_alb_http_router" "web-router" {
  name      = "web-http-router"
  folder_id = var.folder_id
}

# Virtual Host 
resource "yandex_alb_virtual_host" "web-vhost" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web-router.id

  route {
    name = "http-route"

    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }

      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-bg.id
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "web-alb" {
  name       = "web-application-lb"
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.main-network.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-a.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-b.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
      }
    }
  }

}

output "alb_public_ip" {
  description = "Публичный IP Application Load Balancer"
  value       = yandex_alb_load_balancer.web-alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
