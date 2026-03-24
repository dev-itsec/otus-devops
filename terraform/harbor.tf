######################################################################
### harbor ###
######################################################################

data "yandex_compute_image" "harbor_instance_image_name" {
  family = var.harbor_instance.image_name
}

resource "yandex_compute_instance" "harbor_instance" {
  name        = var.harbor_instance.name
  hostname    = var.harbor_instance.name
  zone        = var.yc_zone
  platform_id = var.harbor_instance.cpu_platform

  resources {
    cores         = var.harbor_instance.cores
    memory        = var.harbor_instance.memory
    core_fraction = var.harbor_instance.core_fraction
  }

  boot_disk {
    initialize_params {
      name     = "${var.harbor_instance.name}-boot-disk"
      image_id = data.yandex_compute_image.harbor_instance_image_name.id
      size     = var.harbor_instance.bootdisk_size
      type     = var.harbor_instance.bootdisk_type
    }
  }

    scheduling_policy {
    preemptible = var.harbor_instance.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = var.harbor_instance.nat
    security_group_ids = [yandex_vpc_security_group.harbor_instance_secgroup.id]
  }

  metadata = {
    serial-port-enable = var.serial_port_on 
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }
}

resource "yandex_vpc_security_group" "harbor_instance_secgroup" {
  name        = var.harbor_instance.secgroup
  network_id  = yandex_vpc_network.prod-vpc-network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  
  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

