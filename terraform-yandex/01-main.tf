terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

data "external" "ya_auth" {
  program = ["bash", "yc_vars.sh"]
}

provider "yandex" {
  token     = data.external.ya_auth.result.token
  cloud_id  = data.external.ya_auth.result.cloud_id
  folder_id = data.external.ya_auth.result.folder_id
  zone      = "ru-central1-a"
}

resource "yandex_compute_disk" "cherdantsev-disk" {
  name     = "cherdantsev-disk"
  type     = "network-hdd"
  size     = "20"
  image_id = "fd833v6c5tb0udvk4jo6" # Ubuntu 22.04 LTS
}

resource "yandex_compute_instance" "vm-1" {
  name        = "cherdantsev-yandex-vm"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.cherdantsev-disk.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-1.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.lab5-sg.id] # Привязываем правила портов
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

data "yandex_vpc_network" "default-net" {
  name = "default"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "cherdantsev-subnet"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.default-net.id
  v4_cidr_blocks = ["192.168.101.0/24"] # Изменил на 101, чтобы не конфликтовать с существующими
}

# Настройка портов (Firewall)
resource "yandex_vpc_security_group" "lab5-sg" {
  name       = "cherdantsev-lab5-sg"
  network_id = data.yandex_vpc_network.default-net.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "PostgreSQL"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5432
  }

  ingress {
    protocol       = "TCP"
    description    = "Kafka"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9092
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

output "server_ip" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}