######################################################################
### Network Load Balancer для Ingress Controller Kubernetes
######################################################################

resource "yandex_lb_target_group" "k8s_ingress_tg" {
  name      = "k8s-ingress-tg"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.k8s_ingress[*].network_interface[0].ip_address
    content {
      subnet_id = yandex_vpc_subnet.private-subnet.id
      address   = target.value
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s_ingress_lb" {
  name = "k8s-ingress-lb"

  listener {
    name        = "http-ingress"
    port        = 80      # Внешний порт NLB
    target_port = 30080   # Порт на нодах k8s-ingress (Ingress Controller HTTP)
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "https-ingress"
    port        = 443       # Внешний порт NLB
    target_port = 30443     # Порт на нодах k8s-ingress (Ingress Controller HTTPS)
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_ingress_tg.id

    healthcheck {
      name = "tcp-ingress-hc"
      tcp_options {
        port = 30080 ### если порт будет недоступен, то NLB перестает проксировать на ноду k8s-ingress
      }
    }
  }
}