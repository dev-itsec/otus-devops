resource "yandex_vpc_network" "prod-vpc-network" {
  description    = "Облачная VPC сеть prod-vpc-network"
  name = "prod-vpc-network"
}

resource "yandex_vpc_subnet" "public-subnet" {
  description    = "Подсеть public-subnet для машин с доступом в Интернет"
  name           = var.public_subnet_name
  zone           = var.yc_zone 
  network_id     = yandex_vpc_network.prod-vpc-network.id
  v4_cidr_blocks = ["192.168.100.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet" {
  description = "Подсеть private-subnet для машин без доступа в Интернет"
  name           = var.private_subnet_name
  zone           = var.yc_zone 
  network_id     = yandex_vpc_network.prod-vpc-network.id
  v4_cidr_blocks = ["10.10.10.0/24"]
  route_table_id = yandex_vpc_route_table.nat_instance_route.id # На подсеть private-subnet вешаем таблицу маршрутизации nat-instance-route
}

### Создаем таблицу маршрутизации nat-instance-route и в ней статический маршрут
### Весь трафик 0.0.0.0/0 завернуть на локальный IP машины nat-vm

resource "yandex_vpc_route_table" "nat_instance_route" {
  description    = "Таблица маршрутизации"
  name           = "nat-instance-route"
  network_id     = yandex_vpc_network.prod-vpc-network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface.0.ip_address
  }
}
