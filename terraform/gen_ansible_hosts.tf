### Генерируем inventory для ansible на локальном хосте ../ansible/hosts

locals {
  names_master           = yandex_compute_instance.k8s_master[*].name
  ips_master             = yandex_compute_instance.k8s_master[*].network_interface.0.ip_address
  names_ingress          = yandex_compute_instance.k8s_ingress[*].name
  ips_ingress            = yandex_compute_instance.k8s_ingress[*].network_interface.0.ip_address
  names_node             = yandex_compute_instance.k8s_node[*].name
  ips_node               = yandex_compute_instance.k8s_node[*].network_interface.0.ip_address
}

resource "local_file" "generate_inventory" {
  content = templatefile("ansible_hosts.tpl", {
    names_master           = local.names_master,
    addrs_master           = local.ips_master,
    names_ingress          = local.names_ingress,
    addrs_ingress          = local.ips_ingress,
    names_node             = local.names_node,
    addrs_node             = local.ips_node
  })
  filename = "../ansible/hosts"

  provisioner "local-exec" {
    command = "chmod a-x ../ansible/hosts"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "mv ../ansible/hosts ../ansible/hosts.backup"
    on_failure = continue
  }
}