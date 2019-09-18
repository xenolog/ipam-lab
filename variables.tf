variable "pref" {
  type    = string
  default = "sv"
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

variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbNUC2UJiVk0bHmbVBHd4L22M3Mc3HVPdZZja7gzzUJDI/MIGoTSX8/Q38olBHg6i/9ePzroMqQS70x/LvuEgfKMDUcEBhggq22zea/wohMmMPwiGTEJ3j0CfckXM2cfjRHweHu4U//4SiSgLHi3nnEhYJUvFkOq10qOtZd2iT76sbKpnIEcRVfDcIy01G/wZQLX0SiCk8hWh9ERBqnW2OjNhwG/a2SdoPN25T1HmHAhLJykcGXb7BmrMNe7XFcNsqleMsopTXcqtZBu+ysEbNywPQKUiJrwqOtzkncQwwuKlr53EaXwBY5UHQwoFSXXi28JjmvEZAzA+UBMrPDHrx svasilenko@mrnt"
}

variable "cp_instance_image_name" {
  type    = string
  default = "bionic-server-cloudimg-amd64-20190612"
}

variable "cp_instance_flavor_name" {
  type    = string
  default = "re.jenkins.slave"
}

###