######################################################################
### k8s_master ###
######################################################################

data "yandex_compute_image" "k8s_master_image_name" {
  family = var.k8s_master_config.image_name
}

resource "yandex_compute_instance" "k8s_master" {
  count       = var.k8s_master_count
  name        = "${var.k8s_master_config.name_prefix}-${count.index + 1}"
  hostname    = "${var.k8s_master_config.name_prefix}-${count.index + 1}"
  zone        = var.yc_zone
  platform_id = var.k8s_master_config.cpu_platform

  resources {
    cores         = var.k8s_master_config.cores
    memory        = var.k8s_master_config.memory
    core_fraction = var.k8s_master_config.core_fraction
  }

  boot_disk {
    initialize_params {
      name     = "${var.k8s_master_config.name_prefix}-${count.index + 1}-boot-disk"
      image_id = data.yandex_compute_image.k8s_master_image_name.id
      size     = var.k8s_master_config.bootdisk_size
      type     = var.k8s_master_config.bootdisk_type
    }
  }

    scheduling_policy {
    preemptible = var.k8s_master_config.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet.id
    nat                = var.k8s_master_config.nat
    security_group_ids = [yandex_vpc_security_group.k8s_master_sg.id]
  }

  metadata = {
    serial-port-enable = var.serial_port_on 
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }
}

resource "yandex_vpc_security_group" "k8s_master_sg" {
  name        = var.k8s_master_config.secgroup
  network_id  = yandex_vpc_network.prod-vpc-network.id

  ingress {
    protocol       = "ANY"
    description    = "Allow all ingoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

