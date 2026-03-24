### bastion ###
output "bastion_instance_internal_ip" {
  description = "Внутренний IP-адрес bastion"
  value       = yandex_compute_instance.bastion_instance.network_interface[0].ip_address
}
output "bastion_instance_external_ip" {
  description = "Внешний IP-адрес bastion"
  value       = yandex_compute_instance.bastion_instance.network_interface[0].nat_ip_address
}

### nat-vm ###
output "nat_instance_internal_ip" {
  description = "Внутренний IP-адрес nat-vm"
  value       = yandex_compute_instance.nat_instance.network_interface[0].ip_address
}
output "nat_instance_external_ip" {
  description = "Внешний IP-адрес nat-vm"
  value       = yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address
}

### gitlab ###
output "gitlab_instance_internal_ip" {
  description = "Внутренний IP-адрес gitlab"
  value       = yandex_compute_instance.gitlab_instance.network_interface[0].ip_address
}
output "gitlab_instance_external_ip" {
  description = "Внешний IP-адрес gitlab"
  value       = yandex_compute_instance.gitlab_instance.network_interface[0].nat_ip_address
}

### harbor ###
output "harbor_instance_internal_ip" {
  description = "Внутренний IP-адрес harbor"
  value       = yandex_compute_instance.harbor_instance.network_interface[0].ip_address
}
output "harbor_instance_external_ip" {
  description = "Внешний IP-адрес harbor"
  value       = yandex_compute_instance.harbor_instance.network_interface[0].nat_ip_address
}

### k8s_node ###
output "k8s_node_internal_ips" {
  description = "Внутренние IP-адреса k8s_node"
  value = [
    for vm in yandex_compute_instance.k8s_node :
    vm.network_interface[0].ip_address
  ]
}

### k8s_master ###
output "k8s_master_internal_ips" {
  description = "Внутренние IP-адреса k8s_master"
  value = [
    for vm in yandex_compute_instance.k8s_master :
    vm.network_interface[0].ip_address
  ]
}

### k8s_ingress ###
output "k8s_ingress_internal_ips" {
  description = "Внутренние IP-адреса k8s_ingress"
  value = [
    for vm in yandex_compute_instance.k8s_ingress :
    vm.network_interface[0].ip_address
  ]
}

### NLB Yandex Cloud ###
output "k8s_ingress_lb_ip" {
  description = "Внешний IP-адрес, назначенный NLB"
  value = yandex_lb_network_load_balancer.k8s_ingress_lb.listener.*.external_address_spec[0].*.address
}