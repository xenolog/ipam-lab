resource "local_file" "k8s_file" {
  filename = "${var.output_inventory_file}"
  content  = templatefile("./templates/inventory.tmpl", {
    floating_ip    = openstack_compute_floatingip_associate_v2.cp_instance_floating_ip.floating_ip
    cp             = openstack_compute_instance_v2.cp_instance
    minion_numbers = var.minion_numbers
    minions        = openstack_compute_instance_v2.minion_instance
  })
  depends_on = [
    "openstack_compute_instance_v2.cp_instance",
    "openstack_compute_instance_v2.minion_instance"
  ]
}

output "cp_instance_floating_ip_addr" {
  value = openstack_compute_floatingip_associate_v2.cp_instance_floating_ip.floating_ip
}

output "cp_instance_internal_ip_addr" {
  value = openstack_compute_instance_v2.cp_instance.network.1.fixed_ip_v4
}

output "minions_internal_ip_addrs" {
  value = { for m in values(openstack_compute_instance_v2.minion_instance): m.name => m.network[1].fixed_ip_v4 }
}

###