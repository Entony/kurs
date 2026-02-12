resource "yandex_vpc_network" "main-network" {
  name = "main-network"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.1.0/24"]
  network_id     = yandex_vpc_network.main-network.id
  route_table_id = yandex_vpc_route_table.private-route.id
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.0.2.0/24"]
  network_id     = yandex_vpc_network.main-network.id
  route_table_id = yandex_vpc_route_table.private-route.id
}

resource "yandex_vpc_subnet" "subnet-public" {
  name           = "subnet_public"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.0.0/24"]
  network_id     = yandex_vpc_network.main-network.id
}

resource "yandex_vpc_gateway" "nat-gateway" {
  name = "nat-gateway"

  shared_egress_gateway {}
}


resource "yandex_vpc_route_table" "private-route" {
  name       = "private-route"
  network_id = yandex_vpc_network.main-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
  }
}

