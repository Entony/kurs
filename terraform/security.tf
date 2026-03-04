resource "yandex_vpc_security_group" "web-sg" {
  name       = "web-sg"
  network_id = yandex_vpc_network.main-network.id
  folder_id  = var.folder_id
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
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol          = "TCP"
    port              = 22
    description       = "SSH from bastion"
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
  ingress {
    protocol    = "TCP"
    description = "healthchecks"
    port        = 80
    v4_cidr_blocks = [
      "198.18.232.0/21",
      "198.18.240.0/21",
      "213.180.193.0/24",
      "213.180.194.0/24",
      "213.180.195.0/24",
      "5.255.192.0/18",
      "5.255.224.0/19",
      "77.88.128.0/18",
      "77.88.192.0/18",
      "95.108.128.0/17",
      "130.193.32.0/19",
      "130.193.64.0/18",
      "178.154.128.0/17"
    ]
  }
  ingress {
    protocol       = "TCP"
    port           = 9200
    description    = "Elasticsearch from Kibana"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    protocol       = "TCP"
    port           = 5601
    description    = "Kibana web interface"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    port           = 9200
    description    = "Filebeat to Elasticsearch"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    port              = 10050
    description       = "Zabbix Agent"
    security_group_id = yandex_vpc_security_group.zabbix-server-sg.id
  }
  egress {
    protocol       = "TCP"
    port           = 9200
    description    = "Filebeat to Elasticsearch"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    protocol       = "ICMP"
    description    = "ICMP Ping"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "yandex_vpc_security_group" "bastion-sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.main-network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"] # Желательно ограничить своим IP 
  }
  ingress {
    protocol          = "TCP"
    port              = 10050
    description       = "Zabbix Agent from Server"
    security_group_id = yandex_vpc_security_group.zabbix-server-sg.id
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "ICMP"
    description    = "ICMP Ping"
    v4_cidr_blocks = ["10.0.0.0/16"] # Разрешаем пинг внутри сети VPC
  }
}

resource "yandex_vpc_security_group" "zabbix-server-sg" {
  name       = "zabbix-server-sg"
  network_id = yandex_vpc_network.main-network.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "HTTP Web Interface"
  }

  ingress {
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["10.0.0.0/16"]
    description    = "Zabbix Agent Active Checks"
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    description    = "SSH from VPC (including Bastion)"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["10.0.0.0/16"]
    description    = "To Zabbix Agents"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "ICMP"
    description    = "ICMP Ping"
    v4_cidr_blocks = ["10.0.0.0/16"]
  }
}




