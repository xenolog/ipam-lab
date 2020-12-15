terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.33.0"
    }
  }
}

provider "openstack" {
  cloud = var.clouds_yaml_entry
}

resource "openstack_compute_keypair_v2" "auth_kp" {
  name       = "${var.env_name}__auth_kp"
  public_key = file(local.ssh_public_key_file)
}

#------------------------------------------------------------------------------
data "openstack_networking_network_v2" "external" {
  name = var.ext_network_name
}

resource "openstack_networking_network_v2" "mgmt" {
  name           = "${var.env_name}__mgmt"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "mgmt" {
  name        = "${var.env_name}__mgmt"
  network_id  = openstack_networking_network_v2.mgmt.id
  cidr        = "192.168.1.0/24"
  enable_dhcp = true
  ip_version  = 4
  gateway_ip  = "192.168.1.1"
  // dns_nameservers = ["8.8.8.8","8.8.4.4"]
}

resource "openstack_networking_router_v2" "mgmt" {
  name                = "${var.env_name}__mgmt"
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "mgmt" {
  router_id = openstack_networking_router_v2.mgmt.id
  subnet_id = openstack_networking_subnet_v2.mgmt.id
}
#------------------------------------------------------------------------------
resource "openstack_networking_router_v2" "rack" {
  name           = "${var.env_name}__rack"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "rack" {
  for_each       = { for r in local.rack_networks : r.name => r }
  name           = each.key
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "rack" {
  for_each    = { for r in local.rack_networks : r.name => r }
  name        = each.key
  network_id  = openstack_networking_network_v2.rack[each.key].id
  ip_version  = 4
  cidr        = each.value.cidr
  enable_dhcp = false
  no_gateway  = true
}

resource "openstack_networking_port_v2" "tor" {
  for_each              = { for r in local.rack_networks : r.name => r }
  name                  = each.key
  network_id            = openstack_networking_network_v2.rack[each.key].id
  admin_state_up        = true
  port_security_enabled = false
  # security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_1.id}"]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.rack[each.key].id
    ip_address = each.value.gw
  }
  depends_on = [
    openstack_networking_secgroup_v2.secgroup,
    openstack_networking_router_v2.rack,
    openstack_networking_network_v2.rack,
    openstack_networking_subnet_v2.rack,
  ]
}

resource "openstack_networking_router_interface_v2" "rack" {
  for_each  = { for r in local.rack_networks : r.name => r }
  router_id = openstack_networking_router_v2.rack.id
  port_id   = openstack_networking_port_v2.tor[each.key].id
  depends_on = [
    openstack_networking_port_v2.tor,
  ]
}

resource "openstack_networking_port_v2" "node2rack" {
  for_each              = { for i in local.nodes : i.name => i }
  name                  = each.key
  network_id            = openstack_networking_network_v2.rack[each.value.rack_network].id
  admin_state_up        = true
  port_security_enabled = false
  # security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_1.id}"]

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.rack[each.value.rack_network].id
    ip_address = each.value.rack_ip
  }
  depends_on = [
    openstack_networking_secgroup_v2.secgroup,
    openstack_networking_router_v2.rack,
    openstack_networking_network_v2.rack,
    openstack_networking_subnet_v2.rack,
  ]
}

#------------------------------------------------------------------------------
resource "openstack_networking_secgroup_v2" "secgroup" {
  name                 = "${var.env_name}__secgroup"
  delete_default_rules = true
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress_tcp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress_udp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress_icmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_ingress_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_ingress_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_ingress_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
  depends_on        = [openstack_networking_secgroup_v2.secgroup]
}
#------------------------------------------------------------------------------
data "openstack_images_image_v2" "ubuntu" {
  name = var.instance_image_name
}

resource "openstack_networking_floatingip_v2" "cp_instance_floating_ip" {
  pool = var.floating_if_pool_name
}
resource "openstack_compute_floatingip_associate_v2" "cp_instance_floating_ip" {
  floating_ip = openstack_networking_floatingip_v2.cp_instance_floating_ip.address
  instance_id = openstack_compute_instance_v2.cp_instance[local.cp1st_node.name].id
}

# because it prohibited by policy
# resource "openstack_compute_flavor_v2" "cp_instance_flavor" {
#   name  = "${var.env_name}__cp_instance_flavor"
#   ram   = "8096"
#   vcpus = "4"
#   disk  = "10"
# }
data "openstack_compute_flavor_v2" "cp_instance_flavor" {
  name = var.cp_instance_flavor_name
}

resource "openstack_compute_instance_v2" "cp_instance" {
  for_each = { for i in local.nodes : i.name => i if i.role == "cp" }
  name     = each.key
  image_id = data.openstack_images_image_v2.ubuntu.id
  # flavor_id = "${openstack_compute_flavor_v2.cp_instance_flavor.id}"  // if flavor creation allowed by policy
  flavor_id       = data.openstack_compute_flavor_v2.cp_instance_flavor.id
  key_pair        = openstack_compute_keypair_v2.auth_kp.id
  security_groups = [openstack_networking_secgroup_v2.secgroup.name] // using 'name' is a workaround to repeatly changing name secgroup resource to ID
  user_data = templatefile("./templates/cp1_user_data.tmpl", {
    disable_root = var.ssh_disable_root
    gw           = openstack_networking_subnet_v2.mgmt.gateway_ip
    slave_nodes  = [for node in openstack_compute_instance_v2.minion_instance : node if node.name != local.cp1st_node.name]
  })
  network { // network number #0
    uuid = openstack_networking_network_v2.mgmt.id
  }
  network { // network number #1
    port = openstack_networking_port_v2.node2rack[each.key].id
  }
  depends_on = [
    openstack_networking_secgroup_v2.secgroup,
    # # #openstack_compute_instance_v2.minion_instance,
    openstack_networking_port_v2.node2rack
  ]
}

#------------------------------------------------------------------------------
data "openstack_compute_flavor_v2" "minion_instance_flavor" {
  name = var.minion_instance_flavor_name
}

resource "openstack_compute_instance_v2" "minion_instance" {
  # for_each = toset(var.minion_numbers)
  for_each = { for i in local.nodes : i.name => i if i.role == "minion" }
  name     = each.key
  image_id = data.openstack_images_image_v2.ubuntu.id
  # flavor_id = "${openstack_compute_flavor_v2.minion_instance_flavor.id}"  // if flavor creation allowed by policy
  flavor_id       = data.openstack_compute_flavor_v2.minion_instance_flavor.id
  key_pair        = openstack_compute_keypair_v2.auth_kp.id
  security_groups = [openstack_networking_secgroup_v2.secgroup.name] // using 'name' is a workaround to repeatly changing name secgroup resource to ID

  network { // network number #0
    uuid = openstack_networking_network_v2.mgmt.id
  }
  network { // network number #1
    port = openstack_networking_port_v2.node2rack[each.key].id
  }
  depends_on = [
    openstack_networking_secgroup_v2.secgroup,
    openstack_networking_port_v2.node2rack
  ]
}


###
