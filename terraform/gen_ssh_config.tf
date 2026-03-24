### 

locals {
  bastion_ip = yandex_compute_instance.bastion_instance.network_interface[0].nat_ip_address
}

resource "local_file" "ssh_config_k8s" {
  content = templatefile("ssh_config.tpl", {
    bastion_ip = local.bastion_ip
    ssh_private_key_path = var.ssh_private_key_path
  })
  filename = pathexpand("~/.ssh/config.d/k8s_config")

  provisioner "local-exec" {
    command = "chmod 600 ~/.ssh/config.d/k8s_config"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "mv ~/.ssh/config.d/k8s_config ~/.ssh/config.d/k8s_config.backup"
    on_failure = continue
  }
}
