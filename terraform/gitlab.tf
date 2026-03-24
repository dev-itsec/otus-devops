######################################################################
### gitlab ###
######################################################################

data "yandex_compute_image" "gitlab_instance_image_name" {
  family = var.gitlab_instance.image_name
}

resource "yandex_compute_instance" "gitlab_instance" {
  name        = var.gitlab_instance.name
  hostname    = var.gitlab_instance.name
  zone        = var.yc_zone
  platform_id = var.gitlab_instance.cpu_platform

  resources {
    cores         = var.gitlab_instance.cores
    memory        = var.gitlab_instance.memory
    core_fraction = var.gitlab_instance.core_fraction
  }

  boot_disk {
    initialize_params {
      name     = "${var.gitlab_instance.name}-boot-disk"
      image_id = data.yandex_compute_image.gitlab_instance_image_name.id
      size     = var.gitlab_instance.bootdisk_size
      type     = var.gitlab_instance.bootdisk_type
    }
  }

    scheduling_policy {
    preemptible = var.gitlab_instance.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    nat                = var.gitlab_instance.nat
    security_group_ids = [yandex_vpc_security_group.gitlab_instance_secgroup.id]
  }

  metadata = {
    serial-port-enable = var.serial_port_on 
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }
}

resource "yandex_vpc_security_group" "gitlab_instance_secgroup" {
  name        = var.gitlab_instance.secgroup
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

