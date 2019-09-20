provider "openstack" {
    cloud = "${var.clouds_yaml_entry}"
}

resource "openstack_compute_keypair_v2" "auth_kp" {
  name = "${var.pref}_auth_kp"
  public_key = "${var.ssh_public_key}"
}

#------------------------------------------------------------------------------
data "openstack_networking_network_v2" "external" {
  name = "${var.ext_network_name}"
}

resource "openstack_networking_network_v2" "public" {
    name = "${var.pref}_public"
    admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "public" {
    name = "${var.pref}_public"
    network_id = "${openstack_networking_network_v2.public.id}"
    cidr = "192.168.1.0/24"
    ip_version = 4
    gateway_ip = ""  // .1 will be used as gateway
    // dns_nameservers = ["8.8.8.8","8.8.4.4"]
}

resource "openstack_networking_router_v2" "public" {
    name = "${var.pref}_public"
    admin_state_up = "true"
    external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

resource "openstack_networking_router_interface_v2" "public" {
    router_id = "${openstack_networking_router_v2.public.id}"
    subnet_id = "${openstack_networking_subnet_v2.public.id}"
}
#------------------------------------------------------------------------------
resource "openstack_networking_network_v2" "internal" {
    name = "${var.pref}_internal"
    admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal" {
    name = "${var.pref}_internal"
    network_id = "${openstack_networking_network_v2.internal.id}"
    cidr = "10.10.10.0/24"
    ip_version = 4
    no_gateway = true
    // dns_nameservers = ["8.8.8.8","8.8.4.4"]
}
#------------------------------------------------------------------------------
resource "openstack_networking_secgroup_v2" "secgroup" {
  name                 = "${var.pref}_secgroup"
  delete_default_rules = true
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress_tcp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress_udp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_egress_icmp" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_ingress_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_ingress_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_v4_ingress_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
  depends_on        = ["openstack_networking_secgroup_v2.secgroup"]
}
#------------------------------------------------------------------------------
data "openstack_images_image_v2" "ubuntu" {
  name = "${var.cp_instance_image_name}"
}

resource "openstack_networking_floatingip_v2" "cp_instance_floating_ip" {
  pool = "${var.floating_if_pool_name}"
}
resource "openstack_compute_floatingip_associate_v2" "cp_instance_floating_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.cp_instance_floating_ip.address}"
  instance_id = "${openstack_compute_instance_v2.cp_instance.id}"
}

# because it prohibited by policy
# resource "openstack_compute_flavor_v2" "cp_instance_flavor" {
#   name  = "${var.pref}_cp_instance_flavor"
#   ram   = "8096"
#   vcpus = "4"
#   disk  = "10"
# }
data "openstack_compute_flavor_v2" "cp_instance_flavor" {
  name = "${var.cp_instance_flavor_name}"
}

resource "openstack_compute_instance_v2" "cp_instance" {
  name      = "${var.pref}_cp_instance"
  image_id  = "${data.openstack_images_image_v2.ubuntu.id}"
# flavor_id = "${openstack_compute_flavor_v2.cp_instance_flavor.id}"  // if flavor creation allowed by policy
  flavor_id = "${data.openstack_compute_flavor_v2.cp_instance_flavor.id}"
  key_pair  = "${openstack_compute_keypair_v2.auth_kp.id}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.id}"]

  network {  // network number #0
    uuid = "${openstack_networking_network_v2.public.id}"
  }
  network {  // network number #1
    uuid = "${openstack_networking_network_v2.internal.id}"
  }
}

###