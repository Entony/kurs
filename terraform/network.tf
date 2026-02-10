resource "yandex_vpc_network" "main-network" {
  name = "main-network"
}

resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.1.0/24"]
  network_id     = yandex_vpc_network.main-network.id
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.0.2.0/24"]
  network_id     = yandex_vpc_network.main-network.id
}

resource "yandex_vpc_subnet" "subnet-public" {
  name           = "public_subnet"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.0.0/24"]
  network_id     = yandex_vpc_network.main-network.id
}
