variable "env_name" {
  type    = string
}

variable "minion_numbers" {
  type    = list(string)
  default = ["01", "02"]
}

variable "clouds_yaml_entry" {
  type    = string
  default = "openstack"
}

variable "ext_network_name" {
  type    = string
  default = "public"
}

variable "floating_if_pool_name" {
  type    = string
  default = "public"
}

variable "ssh_private_key_file" {
  type    = string
  default = "~/.ssh/id_rsa"
}
variable "ssh_public_key_file" {
  type    = string
  default = ""
}
locals {
  ssh_public_key_file = "${var.ssh_public_key_file != "" ? var.ssh_public_key_file : "${var.ssh_private_key_file}.pub"}"
}

variable "cp_instance_image_name" {
  type    = string
  default = "bionic-server-cloudimg-amd64-20190612"
}

variable "cp_instance_flavor_name" {
  type    = string
#   default = "re.jenkins.slave"
  default = "dev.cfg"
}

variable "minion_instance_flavor_name" {
  type    = string
#   default = "re.jenkins.slave"
  default = "dev.mon"
}

variable "output_inventory_file" {
  type    = string
  default = "./inventory.yaml"
}

###