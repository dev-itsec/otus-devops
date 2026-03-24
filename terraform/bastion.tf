######################################################################
### bastion ###
######################################################################

data "yandex_compute_image" "bastion_instance_image_name" {
  family = var.bastion_instance.image_name
}

resource "yandex_compute_instance" "bastion_instance" {
  name        = var.bastion_instance.name
  hostname    = var.bastion_instance.name
  zone        = var.yc_zone
  platform_id = var.bastion_instance.cpu_platform

  resources {
    cores         = var.bastion_instance.cores
    memory        = var.bastion_instance.memory
    core_fraction = var.bastion_instance.core_fraction
  }

  boot_disk {
    initialize_params {
      name     = "${var.bastion_instance.name}-boot-disk"
      image_id = data.yandex_compute_image.bastion_instance_image_name.id
      size     = var.bastion_instance.bootdisk_size
      type     = var.bastion_instance.bootdisk_type
    }
  }

    scheduling_policy {
    preemptible = var.bastion_instance.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = var.bastion_instance.public_nat
    security_group_ids = [yandex_vpc_security_group.bastion_instance_public_secgroup.id]
  }

  network_interface {
  subnet_id          = yandex_vpc_subnet.private-subnet.id
  nat                = var.bastion_instance.private_nat
  security_group_ids = [yandex_vpc_security_group.bastion_instance_private_secgroup.id]
}

  metadata = {
    serial-port-enable = var.serial_port_on 
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }
}

resource "yandex_vpc_security_group" "bastion_instance_public_secgroup" {
  name        = var.bastion_instance.public_secgroup
  network_id  = yandex_vpc_network.prod-vpc-network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion_instance_private_secgroup" {
  name        = var.bastion_instance.private_secgroup
  network_id  = yandex_vpc_network.prod-vpc-network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

