resource "yandex_compute_instance_group" "web-instance-group" {
  name               = "web-ig"
  folder_id          = var.folder_id
  service_account_id = var.service_account_id
  instance_template {

    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.main_image.id
        type     = "network-hdd"
        size     = 20
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.main-network.id
      security_group_ids = [yandex_vpc_security_group.web-sg.id]
      subnet_ids = [
        yandex_vpc_subnet.subnet-a.id,
        yandex_vpc_subnet.subnet-b.id
      ]

      nat = true
    }

    metadata = {
      user-data = templatefile("config.tpl", {
        VM_USER = var.vm_user
        SSH_KEY = var.ssh_key
      })

    }

  }

  scale_policy {
    auto_scale {
      initial_size           = 2
      measurement_duration   = 60
      cpu_utilization_target = 40
      min_zone_size          = 1
      max_size               = 3
      warmup_duration        = 120
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b"
    ]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name        = yandex_alb_target_group.web-tg.name
    target_group_description = "Target group for ALB"
  }
}


# Создание сетевого балансировщика

resource "yandex_lb_network_load_balancer" "balancer" {
  name = "group-balancer"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.web-instance-group.load_balancer[0].target_group_id
    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }
}

// 1. Target Group (ALB, а не NLB!)
resource "yandex_alb_target_group" "web-tg" {
  name = "web-target-group"
  // ВМ добавятся автоматически из Instance Group
}

// 2. Backend Group (с HTTP-healthcheck)
resource "yandex_alb_backend_group" "web-bg" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web-tg.id]

    healthcheck {
      http_healthcheck {
        port          = 80
        path          = "/" // healthcheck на корень
        http_versions = ["HTTP1"]
      }
      timeout             = "10s"
      interval            = "30s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }
}

// 3. HTTP Router (маршрутизация по пути /)
resource "yandex_alb_http_router" "web-router" {
  name = "web-http-router"

  virtual_host {
    name = "default-host"

    route {
      name = "http-route"
      http_route {
        http_match {
          path { exact = "/" } // путь /
        }
        http_action {
          backend_group_id = yandex_alb_backend_group.web-bg.id
        }
      }
    }

    healthcheck { path = "/" }
  }
}

// 4. Application Load Balancer
resource "yandex_alb_load_balancer" "web-alb" {
  name = "web-application-lb"

  listener {
    name = "http-listener"
    port = 80

    endpoint {
      address {
        external_ipv4_address { address = "auto" }
      }
    }
  }

  http_router {
    http_router_id = yandex_alb_http_router.web-router.id
  }

  network_id         = yandex_vpc_network.main-network.id
  security_group_ids = [yandex_vpc_security_group.web-sg.id]
}


