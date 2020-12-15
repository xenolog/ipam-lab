variable "env_name" {
  type    = string
  default = "multirack-lab"
}


variable "racks_base_subnet" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cp_amount" {
  type    = list(number)
  default = [1, 0]
}

variable "minion_amount" {
  type    = list(number)
  default = [1, 1]
}

locals {
  rack_amount                = length(var.minion_amount) >= length(var.cp_amount) ? length(var.minion_amount) : length(var.cp_amount)
  node_amount                = [for rackNo in range(local.rack_amount) : var.cp_amount[rackNo] + var.minion_amount[rackNo]]
  splitted_racks_base_subnet = split(".", var.racks_base_subnet)
  rack_networks = flatten([for rackNo in range(local.rack_amount) : {
    name = format("%s__rack-%02d", var.env_name, rackNo + 1)
    #todo(sv): fix this shit !!!
    base = format("%s.%s.%s", local.splitted_racks_base_subnet[0], local.splitted_racks_base_subnet[1], rackNo + 1)
    cidr = format("%s.%s.%s.0/24", local.splitted_racks_base_subnet[0], local.splitted_racks_base_subnet[1], rackNo + 1)
    gw   = format("%s.%s.%s.253", local.splitted_racks_base_subnet[0], local.splitted_racks_base_subnet[1], rackNo + 1)
    }
  ])
  nodes = flatten([
    for rackNo in range(local.rack_amount) : [
      for nodeInRackNo in range(local.node_amount[rackNo]) : {
        name         = format("%s__node-%02d%03d", var.env_name, rackNo + 1, nodeInRackNo + 1)
        node_num     = nodeInRackNo + 1
        role         = nodeInRackNo >= var.cp_amount[rackNo] ? "minion" : "cp"
        rack_network = local.rack_networks[rackNo].name
        rack_ip      = format("%s.%d", local.rack_networks[rackNo].base, nodeInRackNo + 1)
      }
    ]
  ])
  cp1st_node = [for i in local.nodes : i if i.role == "cp"][0]
}

variable "rack_amount" {
  type    = number
  default = 2
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
  ssh_public_key_file = var.ssh_public_key_file != "" ? var.ssh_public_key_file : "${var.ssh_private_key_file}.pub"
}

variable "instance_image_name" {
  type    = string
  default = "focal-server-cloudimg-amd64-20200914"
}

variable "cp_instance_flavor_name" {
  type = string
  #   default = "re.jenkins.slave"
  default = "dev.cfg"
}

variable "minion_instance_flavor_name" {
  type = string
  #   default = "re.jenkins.slave"
  default = "dev.mon"
}

variable "ssh_disable_root" {
  type    = bool
  default = false
}

variable "k8s_dashboard" {
  type    = bool
  default = true
}

variable "output_inventory_file_name" {
  type    = string
  default = "inventory.yaml"
}

variable "kubespray_network_plugin" {
  type    = string
  default = "flannel"
}

###
