output "cp_instance_floating_ip_addr" {
  value = openstack_compute_floatingip_associate_v2.cp_instance_floating_ip.floating_ip
}

# output "cp_instance_internal_ip_addr" {
#   value = openstack_compute_instance_v2.cp_instance.network.1.fixed_ip_v4
# }
