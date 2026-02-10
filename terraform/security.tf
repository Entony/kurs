resource "yandex_vpc_security_group" "web-sg" {
  name       = "sg"
  network_id = yandex_vpc_network.main-network.id
  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol          = "TCP"
    port              = 22
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion.id
  }
  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }
}

resource "yandex_vpc_security_group" "bastion-sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.main-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"] # Ограничить своим IP в продакшене
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
