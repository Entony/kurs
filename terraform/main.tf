# Настройка провайдера

resource "yandex_resourcemanager_folder_iam_member" "ig-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${var.service_account_id}"
}

# Для балансировщика может понадобиться:
resource "yandex_resourcemanager_folder_iam_member" "lb-admin" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${var.service_account_id}"
}

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.95.0"
    }
  }
}

provider "yandex" {
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "main_image" {
  family = "ubuntu-2404-lts"
}
