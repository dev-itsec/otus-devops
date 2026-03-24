variable "yc_token" {}
variable "yc_cloud_id" {}
variable "yc_folder_id" {}
variable "yc_zone" {}

variable "ssh_username" {}
variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}
variable "serial_port_on" {
  type = number
}

variable "public_subnet_name" {}
variable "private_subnet_name" {}

variable "bastion_instance" {
  description = "Параметры виртуальной машины bastion"
  type = object({
    name               = string
    image_name         = string
    cores              = number
    cpu_platform       = string
    core_fraction      = number
    memory             = number
    bootdisk_size      = number
    bootdisk_type      = string
    preemptible        = bool
    public_nat         = bool
    private_nat        = bool
    public_secgroup    = string
    private_secgroup  = string
  })
}

variable "nat_instance" {
  description = "Параметры виртуальной машины nat-vm"
  type = object({
    name               = string 
    image_name         = string
    cores              = number
    cpu_platform       = string
    core_fraction      = number
    memory             = number
    bootdisk_size      = number
    bootdisk_type      = string
    preemptible        = bool
    nat                = bool
    secgroup           = string
  })
}

variable "gitlab_instance" {
  description = "Параметры виртуальной машины gitlab"
  type = object({
    name               = string
    image_name         = string
    cores              = number
    cpu_platform       = string
    core_fraction      = number
    memory             = number
    bootdisk_size      = number
    bootdisk_type      = string
    preemptible        = bool
    nat                = bool
    secgroup           = string
  })
}

variable "harbor_instance" {
  description = "Параметры виртуальной машины harbor"
  type = object({
    name               = string
    image_name         = string
    cores              = number
    cpu_platform       = string
    core_fraction      = number
    memory             = number
    bootdisk_size      = number
    bootdisk_type      = string
    preemptible        = bool
    nat                = bool
    secgroup           = string
  })
}

##################################
### K8s Cluster ###
##################################

variable "k8s_master_count" {
  type = number
}

variable "k8s_master_config" {
  description = "Параметры одинаковых Kubernetes-master"
  type = object({
    name_prefix        = string
    image_name         = string
    cores              = number
    cpu_platform       = string
    core_fraction      = number
    memory             = number
    bootdisk_size      = number
    bootdisk_type      = string
    preemptible        = bool
    nat                = bool
    secgroup           = string
  })
}

variable "k8s_ingress_count" {
  type = number
}

variable "k8s_ingress_config" {
  description = "Параметры одинаковых Kubernetes-ingress"
  type = object({
    name_prefix        = string
    image_name         = string
    cores              = number
    cpu_platform       = string
    core_fraction      = number
    memory             = number
    bootdisk_size      = number
    bootdisk_type      = string
    preemptible        = bool
    nat                = bool
    secgroup           = string
  })
}

variable "k8s_node_count" {
  type = number
}

variable "k8s_node_config" {
  description = "Параметры одинаковых Kubernetes-node"
  type = object({
    name_prefix       = string
    image_name        = string
    cores             = number
    cpu_platform      = string
    core_fraction     = number
    memory            = number
    bootdisk_size     = number
    bootdisk_type     = string
    preemptible       = bool
    nat               = bool    
    secgroup          = string
  })
}
