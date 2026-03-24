######################################################################
### nat-vm ###
######################################################################

data "yandex_compute_image" "nat_instance_image_name" {
  family = var.nat_instance.image_name
}

resource "yandex_compute_instance" "nat_instance" {
  name        = var.nat_instance.name
  hostname    = var.nat_instance.name  
  zone        = var.yc_zone
  platform_id = var.nat_instance.cpu_platform

  resources {
    cores         = var.nat_instance.cores
    memory        = var.nat_instance.memory
    core_fraction = var.nat_instance.core_fraction
  }

  boot_disk {
    initialize_params {
      name     = "${var.nat_instance.name}-boot-disk"
      image_id = data.yandex_compute_image.nat_instance_image_name.id
      size     = var.nat_instance.bootdisk_size
      type     = var.nat_instance.bootdisk_type
    }
  }

    scheduling_policy {
    preemptible = var.nat_instance.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = var.nat_instance.nat
    security_group_ids = [yandex_vpc_security_group.nat_instance_secgroup.id]
  }

  metadata = {
    serial-port-enable = var.serial_port_on 
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }
}

resource "yandex_vpc_security_group" "nat_instance_secgroup" {
  name        = var.nat_instance.secgroup
  network_id  = yandex_vpc_network.prod-vpc-network.id

  ingress {
    protocol       = "ANY"
    description    = "Allow all ingoing traffic" # Разрешаем все входящие, иначе трафик из private-subnet будет блокироваться
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

