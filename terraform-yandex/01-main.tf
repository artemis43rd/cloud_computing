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
  image_id = "fd833v6c5tb0udvk4jo6"
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
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
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
  v4_cidr_blocks = ["192.168.101.0/24"]
}

output "server_ip" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}